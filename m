From: Szeredi Miklos <mszeredi@inf.bme.hu>
Subject: Wake on Lan with epic100
Date: Thu, 21 Aug 2003 22:25:26 +0200 (MET DST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308212025.h7LKPQ225880@kempelen.iit.bme.hu>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

I'm trying to set up an SMC Etherpower II card to perform a WOL,
without success.  The WOL connector is connected to the motherboard,
and WOL is enabled in the BIOS.

Am I correct in assuming, that this is a driver issue?  I.e. the
driver should initialize the card to receive WOL packet and signal the
host to wake up.  Are there some datasheets for this chipset which
describe, how this should be done?

Thanks,
Miklos Szeredi
