From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Sat, 13 Aug 2011 18:01:59 -0700 (PDT)
Message-ID: <20110813.180159.1540694388210461647.davem@davemloft.net>
References: <1313118445-25594-1-git-send-email-wangshaoyan.pt@taobao.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sebastian.poehn@belden.com, wangshaoyan.pt@taobao.com
To: stufever@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758Ab1HNBCH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2011 21:02:07 -0400
In-Reply-To: <1313118445-25594-1-git-send-email-wangshaoyan.pt@taobao.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: stufever@gmail.com
Date: Fri, 12 Aug 2011 11:07:25 +0800

> From: Wang Shaoyan <wangshaoyan.pt@taobao.com>
>=20
>   drivers/net/gianfar_ethtool.c:765: warning: the frame size of 2048 =
bytes is larger than 1024 bytes
>=20
> Signed-off-by: Wang Shaoyan <wangshaoyan.pt@taobao.com>
> Reviewed-and-tested-by: Sebastian P=F6hn <sebastian.poehn@belden.com>

Applied.
