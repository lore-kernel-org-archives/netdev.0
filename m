From: David Dillow <dave@thedillows.org>
Subject: [BK] Typhoon net driver fixes for 2.4
Date: 27 Jun 2003 00:52:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056689562.8679.36.camel@ori.thedillows.org>
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

 drivers/net/typhoon.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

through these ChangeSets:

<dave@thedillows.org> (03/06/27 1.1029)
   Fix misreporting of card type and spurious
   "already scheduled" messages.
