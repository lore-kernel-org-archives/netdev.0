From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: Level One LXT1001 GE chip
Date: Wed, 26 Nov 2003 02:02:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC3FB99.70700@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi,

Months ago I sent a question to netdev to know if SMC TigerCard 1000
(SMC9462SX) was supported under LiNUX. Today I know that the answer
is NO, officially. Maybe because it's little extended and it's an strange
chip with only a few clone boards out there, smc dlink planex...

I got more info from FreeBSD:

"The lge driver provides support for various NICs based on the Level 1
LXT1001 NetCellerator gigabit ethernet controller chip, including the
following:

o SMC TigerCard 1000 (SMC9462SX)
o D-Link DGE-500SX

These NICs are capable of 1000mbps speeds over fiber optic cable. The
LXT1001 also supports a GMII port for use with 10/100/1000 copper PHYs,
however there aren't currently any NICs on the market that use this fea-
ture."

Searching arround NET I found the LXT1001 Developer Manual:
http://people.freebsd.org/~wpaul/Level1/LXT1001SRM.pdf
and an unofficial LiNUX 2.4 driver, 2002/01/22, v 1.04.05, under an
ugly URL:
http://tsd.dlink.com.tw/info.nsf/80d023dbef05f90048256adf002a91be/ee44db010731cedb48256c9f00248656?OpenDocument

'wpaul' looks like the official ethernet drivers writer for *BSD
and he has _lot of NET manuals/docs_ under his $HOME:
http://people.freebsd.org/~wpaul/

If someone complains about this NIC, he/she already has information
to write a better driver. I only use intel NICs ;-)

-thanks for your time-
--
HTML mails are going to trash automagically
