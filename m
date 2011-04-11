From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/2] bonding:delete two unused variables
Date: Mon, 11 Apr 2011 12:02:09 -0700
Message-ID: <30720.1302548529@death>
References: <cover.1302509480.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?q?Weiping=20Pan=28=E6=BD=98=E5=8D=AB=E5=B9=B3=29?=
	<panweiping3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <cover.1302509480.git.panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>I found that variable alb_timer and rlb_interval_counter in struct
>alb_bond_info are not used by other codes any more, so delete them.
>
>Weiping Pan(=E6=BD=98=E5=8D=AB=E5=B9=B3) (2):
>  bonding:delete unused alb_timer
>  bonding:delete unused rlb_interval_counter

	For both patches.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


> drivers/net/bonding/bond_alb.h |    2 --
> 1 files changed, 0 insertions(+), 2 deletions(-)
>
>--=20
>1.7.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
