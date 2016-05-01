From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Sun, 1 May 2016 17:27:02 +0200
Message-ID: <20160501152702.GB1947@nanopsycho.orion>
References: <20160427151336.GB1962@nanopsycho.orion>
 <20160427.125506.1088576804354580011.davem@davemloft.net>
 <5721FB26.6070305@6wind.com>
 <20160428.115419.1831238411921569629.davem@davemloft.net>
 <57231FD1.2080907@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34341 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbcEAP1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 11:27:05 -0400
Received: by mail-wm0-f68.google.com with SMTP id n129so13741715wmn.1
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 08:27:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57231FD1.2080907@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Apr 29, 2016 at 10:48:17AM CEST, nicolas.dichtel@6wind.com wrote=
:
>Le 28/04/2016 17:54, David Miller a =E9crit :
>[snip]
>> You can say whatever you want, but the facilities you are adding to
>> this driver enables proprietary userland SDK components.
>>=20
>> And this is precisely what we are trying to avoid by having a clean,
>> fully featured switch device model in the kernel.
>>=20
>> It is against your interestes of upstreaming your driver to continue
>> denying what your changes facilitate.
>Ok, I will rework this patch to remove the controversial parts and cus=
tom APIs.

I'm pretty sure that means removing the whole patch... Seriously, this
is wrong.
