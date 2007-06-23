From: Geoff Levand <geoffrey.levand@am.sony.com>
Subject: Re: [PATCH] ps3: gigabit ethernet driver for PS3, take2
Date: Sat, 23 Jun 2007 11:09:04 -0700
Message-ID: <467D61C0.5040006@am.sony.com>
References: <20070619183956.F224.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: MOKUNO Masakazu <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-fra.frontbridge.com ([62.209.45.174]:15984 "EHLO
	outbound3-fra-R.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753369AbXFWSJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 14:09:54 -0400
In-Reply-To: <20070619183956.F224.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MOKUNO Masakazu wrote:
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -2920,6 +2920,12 @@ M:	mikpe@it.uu.se
>  L:	linux-ide@vger.kernel.org
>  S:	Maintained
>  
> +PS3 NETWORK SUPPORT
> +P:	Masakazu Mokuno
> +M:	mokuno@sm.sony.co.jp
> +L:	netdev@vger.kernel.org


I think you should put cbe-oss-dev@ozlabs.org for
the mail list.  Users will get better support
and I will be able to keep track of the inquiries.

All PS3 developers monitor cbe-oss-dev@ozlabs.org,
but few if any monitor netdev@vger.kernel.org.

-Geoff


