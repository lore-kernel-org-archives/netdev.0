From: David Dillow <dave@thedillows.org>
Subject: [BK] Typhoon (3CR990) updates for 2.5
Date: 26 Nov 2003 23:09:05 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069906145.4552.8.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff, please do a

bk pull http://typhoon.bkbits.net/typhoon-2.5

This will update the following files:

drivers/net/typhoon.c |   97 ++++++++++++++++++++++++++++++++++++++++--
1 files changed, 78 insertions(+), 19 deletions(-)

through these ChangeSets:

<dave@thedillows.org> (03/11/26 1.1487)
   Bug fixes:
   * Avoid short timeouts when waiting for a reset
   * Fix issue with loading runtime image on newer versions of
the sleep image
   * Fix link status reporting
