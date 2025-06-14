import asyncio
from kasa import SmartPlug

async def main():
    plug = SmartPlug("192.168.5.132")
    await plug.update()  # Fetch current state
    print(f"Current state: {plug.is_on}")
    # await plug.turn_on()  # Turn on the plug
    # await plug.update()
    # print(f"New state: {plug.is_on}")

if __name__ == "__main__":
    asyncio.run(main())