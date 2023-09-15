const { Contract } = require("fabric-contract-api");
const crypto = require("crypto");
const ULID = require('ulid');

class LotContract extends Contract {
  constructor() {
    super("LotContract");
  }

  async getQueryResult(ctx, query) {
    const result = []
    for await (const { value } of ctx.stub.getQueryResult(query)) {
      result.push(JSON.parse(value.toString()))
    }

    return result
  }

  async getAttribute(ctx, value) {
    return ctx.clientIdentity.getAttributeValue(value);
  }
 
  async getUser(ctx) {
    const id = await ctx.clientIdentity.getID()
    const user = id.match(/CN=(.*?)\:\:/i)[1]
    return user
  }

  async getStarted(ctx) {
    const user = await this.getUser(ctx)

    const query = {
      selector: {
        createdBy: user,
        "fishing.coldchain": {
          $exists: false
        },
        "fishing.geolocation": {
          $exists: false
        }
     }
    }
    const queryString = JSON.stringify(query)
    return await this.getQueryResult(ctx, queryString)
  }

  async instantiate() {
    // function that will be invoked on chaincode instantiation
  }

  async start(ctx, value) {
    const user = await this.getUser(ctx)

    const nStartedLots = (await this.getStarted(ctx)).length
    if (nStartedLots > 0) { return { error: "MULTIPLE_STARTED_LOTS" } }

    const key = ULID.ulid()
    const flatLot = JSON.parse(value)

    const structuredLot = {
      id: key,
      createdBy: user,
      vessel: flatLot.vessel,
      owner: flatLot.owner,
      shipping: {
        timestamp: new Date().toISOString(),
        port: flatLot.port
      },
      fishing: {
        specie: flatLot.specie,
        gear: flatLot.gear
      }
    }
    
    await ctx.stub.putState(key, Buffer.from(JSON.stringify(structuredLot)));
    return structuredLot;
  }

  async finish(ctx, value) {
    const nStartedLots = (await this.getStarted(ctx)).length
    if (nStartedLots === 0) { return { error: "NO_STARTED_LOTS" } }
    
    const lot = await this.getCurrent(ctx)
    const newData = JSON.parse(value)
    
    const updatedLot = {
      ...lot,
      landing: {
        timestamp: new Date().toISOString(),
        port: newData.port,
        volume: newData.volume
      }
    }
    
    await ctx.stub.putState(lot.id, Buffer.from(JSON.stringify(updatedLot)));
    return updatedLot;
  }

  async get(ctx, key) { 
    const buffer = await ctx.stub.getState(key);
    if (!buffer || !buffer.length) return { error: "NOT_FOUND" };
    return buffer.toString()
  }

  async getCurrent(ctx) {
    const startedLots = await this.getStarted(ctx)
    if (startedLots.length === 0) { return { info: "NO_STARTED_LOTS" } }
    if (startedLots.length > 1) { return { error: "MULTIPLE_STARTED_LOTS" } }
    return startedLots[0] 
  }

  async getAll(ctx) {
    const query = {
      selector:{
        landing:{
          $exists: true
        }
      }
    }
    const queryString = JSON.stringify(query)
    return await this.getQueryResult(ctx, queryString)
  }

  async addFiles(ctx, value) {
    const nStartedLots = (await this.getStarted(ctx)).length
    if (nStartedLots === 0) { return { error: "NO_STARTED_LOTS" } }

    const files = JSON.parse(value)
    const lot = (await this.getCurrent(ctx))
    lot.fishing.geolocation = files.geolocation
    lot.fishing.coldchain = files.coldchain

    await ctx.stub.putState(lot.id, Buffer.from(JSON.stringify(lot)));
    return JSON.stringify(lot);
  }
}
exports.contracts = [LotContract];
