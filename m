From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH 00/12]Next:Get rid of all the old micro DMA_XXBIT_MASK
 and use DMA_BIT_MASK(n) instead
Date: Thu, 19 Feb 2009 16:52:44 +0800
Message-ID: <499D1DDC.50905@cn.fujitsu.com>
References: <499CFDC8.1070600@cn.fujitsu.com> <20090219064932.GB3296@hack.private>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60488 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752070AbZBSIvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 03:51:24 -0500
In-Reply-To: <20090219064932.GB3296@hack.private>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am=E9rico Wang wrote:
> On Thu, Feb 19, 2009 at 02:35:52PM +0800, Yang Hongyang wrote:
>> Replace all DMA_XXBIT_MASK micro with new DMA_BIT_MASK(n) micro
>>
>> 01:Replace all DMA_64BIT_MASK micro with DMA_BIT_MASK(64)
>> 02:Replace all DMA_48BIT_MASK micro with DMA_BIT_MASK(48)
>> 03:Replace all DMA_40BIT_MASK micro with DMA_BIT_MASK(40)
>> 04:Replace all DMA_39BIT_MASK micro with DMA_BIT_MASK(39)
>> 05:Replace all DMA_35BIT_MASK micro with DMA_BIT_MASK(35)
>> 06:Replace all DMA_32BIT_MASK micro with DMA_BIT_MASK(32)
>> 07:Replace all DMA_31BIT_MASK micro with DMA_BIT_MASK(31)
>> 08:Replace all DMA_30BIT_MASK micro with DMA_BIT_MASK(30)
>> 09:Replace all DMA_28BIT_MASK micro with DMA_BIT_MASK(28)
>> 10:Replace all DMA_24BIT_MASK micro with DMA_BIT_MASK(24)
>> 11:Remove defines of DMA_XXBIT_MASK micro
>> 12:Update related documentations
>=20
> s/micro/macro/
>=20
>=20

Will fix,Thank you!~

--=20
Regards
Yang Hongyang
