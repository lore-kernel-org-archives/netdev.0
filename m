From: David Dillow <dave@thedillows.org>
Subject: [BK netdev-2.6] Update Typhoon firmware
Date: Fri, 17 Dec 2004 15:07:05 -0500
Message-ID: <1103314025.4217.1.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff, please do a

	bk pull http://typhoon.bkbits.net/typhoon-2.6-firmware

This will update the following files:

 drivers/net/typhoon-firmware.h | 5568 ++++++++++++++++++-----------------------
 drivers/net/typhoon.c          |   13 
 2 files changed, 2533 insertions(+), 3048 deletions(-)

through these ChangeSets:

<dave@thedillows.org> (04/12/17 1.2099)
   Update the Typhoon firmware to the latest version from 3Com.


Due to the size of the patch (~400K), I've put it up at
http://www.thedillows.org/typhoon-firmware-03.001.008.patch.bz2

-- 
David Dillow <dave@thedillows.org>
