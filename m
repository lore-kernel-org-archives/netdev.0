From: Dave Dillow <ddillow@idleaire.com>
Subject: [BK RESEND] Typhoon (3CR990) updates for 2.4
Date: 03 Dec 2003 16:42:49 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1070487769.5062.4.camel@dillow.idleaire.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff, please do a

bk pull http://typhoon.bkbits.net/typhoon-2.4

This will update the following files:

drivers/net/typhoon.c |   97 ++++++++++++++++++++++++++++++++++++++++--
1 files changed, 78 insertions(+), 19 deletions(-)

through these ChangeSets:

<dave@thedillows.org> (03/11/25 1.1063.47.1)
   Bug fixes:
   * Avoid short timeouts when waiting for a reset
   * Support newer versions of the sleep image
   * Fix link status reporting
