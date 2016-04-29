From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Fri, 29 Apr 2016 10:48:17 +0200
Message-ID: <57231FD1.2080907@6wind.com>
References: <20160427151336.GB1962@nanopsycho.orion>
 <20160427.125506.1088576804354580011.davem@davemloft.net>
 <5721FB26.6070305@6wind.com>
 <20160428.115419.1831238411921569629.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jiri@resnulli.us, fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35698 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbcD2IsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 04:48:21 -0400
Received: by mail-wm0-f42.google.com with SMTP id e201so18567604wme.0
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 01:48:19 -0700 (PDT)
In-Reply-To: <20160428.115419.1831238411921569629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/04/2016 17:54, David Miller a =E9crit :
[snip]
> You can say whatever you want, but the facilities you are adding to
> this driver enables proprietary userland SDK components.
>=20
> And this is precisely what we are trying to avoid by having a clean,
> fully featured switch device model in the kernel.
>=20
> It is against your interestes of upstreaming your driver to continue
> denying what your changes facilitate.
Ok, I will rework this patch to remove the controversial parts and cust=
om APIs.


Thank you,
Nicolas
