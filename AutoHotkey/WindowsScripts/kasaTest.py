import asyncio
from kasa.iot import IotPlug

async def main():
    plug = await IotPlug.connect("192.168.5.132")
    await plug.update()  # Fetch current state
    print(f"Current state: {plug.is_on}")
    # await plug.turn_on()  # Turn on the plug
    # await plug.update()
    # print(f"New state: {plug.is_on}")

if __name__ == "__main__":
    asyncio.run(main())