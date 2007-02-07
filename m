From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [IPROUTE2] tc build failure and netfilter headers.
Date: Tue, 6 Feb 2007 23:53:53 -0800
Message-ID: <20070206235353.2b39fb3a@oldman>
References: <20070207.163353.86698058.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37773 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161017AbXBGHyE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 02:54:04 -0500
In-Reply-To: <20070207.163353.86698058.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 07 Feb 2007 16:33:53 +0900 (JST)
YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <yoshfuji@linu=
x-ipv6.org> wrote:

> Stephen,
>=20
> I think we should include include/linux/netfilter/{x_tables.h,xt_tcpu=
dp.h}
> in iproute2 distribution to avoid compilation failure of tc.
>=20
> Regards,
>=20
> --yoshfuji

Okay, but but we are suffering from header creep
