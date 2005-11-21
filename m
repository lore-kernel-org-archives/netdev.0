From: Robert Iakobashvili <coroberti@gmail.com>
Subject: Netlink send from the interrupt context
Date: Mon, 21 Nov 2005 13:16:54 +0200
Message-ID: <7e63f56c0511210316l70d8608fn593f27f37ec28155@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Are there netlink socket netlink_unicast () and netlink_broadcast ()
interrupt safe?

If not, where is the problem and the direction to make them safe?
If it is not easy, what could be a workaroud?

Thank you in advance.
----------------------------------------------------------------
Robert Iakobashvili  - NAVIGARE NECESSE EST
coroberti at gmail dot com
---------------------------------------------------------------
