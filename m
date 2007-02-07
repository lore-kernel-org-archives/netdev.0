From: Levitsky Maxim <maximlevitsky@yahoo.com>
Subject: [PATCH] [NETDEV] [000]  dmfe : fix bugs and add features
Date: Wed, 7 Feb 2007 10:26:56 -0800 (PST)
Message-ID: <96797.60132.qm@web38511.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tori@unhappy.mine.nu, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965707AbXBGS06@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Before some time I decided to fix suspend/resume on my Davicom network =
card.
During development I also fixed couple of bugs and added support for li=
nk detection and WOL
Note : 2.6.20 already has support for link detection , but it is broken=
 when card has external PHY
, like mine.

So here it goes:

[PATCH] [NET] [001] dmfe : trivial/spelling fixes
[PATCH] [NET] [002] dmfe : Fix possible oops
[PATCH] [NET] [003] dmfe : fix link detection
[PATCH] [NET] [004] dmfe : Add suspend/resume support
[PATCH] [NET] [005] dmfe : Add support for wake-on-lan

=A0 =A0 =A0 =A0 Maxim Levitsky


=20
_______________________________________________________________________=
_____________
=46inding fabulous fares is fun. =20
Let Yahoo! FareChase search your favorite travel sites to find flight a=
nd hotel bargains.
http://farechase.yahoo.com/promo-generic-14795097
