From: =?UTF-8?q?Weiping=20Pan=28=E6=BD=98=E5=8D=AB=E5=B9=B3=29?=
	<panweiping3@gmail.com>
Subject: [PATCH 0/2] bonding:delete two unused variables
Date: Mon, 11 Apr 2011 16:17:23 +0800
Message-ID: <cover.1302509480.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?q?Weiping=20Pan (=E6=BD=98=E5=8D=AB=E5=B9=B3) ?=
	<panweiping3@gmail.com>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I found that variable alb_timer and rlb_interval_counter in struct
alb_bond_info are not used by other codes any more, so delete them.

Weiping Pan(=E6=BD=98=E5=8D=AB=E5=B9=B3) (2):
  bonding:delete unused alb_timer
  bonding:delete unused rlb_interval_counter

 drivers/net/bonding/bond_alb.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

--=20
1.7.4
