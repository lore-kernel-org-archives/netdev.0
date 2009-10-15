From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH net-next 0/5] Phonet: basic routing support
Date: Thu, 15 Oct 2009 14:58:05 +0200
Message-ID: <3a7a7527184221041233e9ade71e4bf1@chewa.net>
References: <06dcdf33b2a0132b2a05c3220735a81e@chewa.net> <20091014.150843.59514584.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36040 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932279AbZJOM6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 08:58:42 -0400
In-Reply-To: <20091014.150843.59514584.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 14 Oct 2009 15:08:43 -0700 (PDT), David Miller=0D
<davem@davemloft.net> wrote:=0D
> From: R=C3=A9mi Denis-Courmont <remi@remlab.net>=0D
> Date: Wed, 14 Oct 2009 12:47:34 +0200=0D
> =0D
>>=0D
>> This patchset provides rudimentary support for routing Phonet packet=
s.=0D
>> Configuration is done with the common rtnetlink infrastructure.=0D
>>=0D
>> This is useful when there is more than one Phonet interface in the s=
ame=0D
>> namespace,=0D
>> e.g. a serial bus to a cellular modem and a USB gadget function to a=
 PC.=0D
> =0D
> Looks good, applied to net-next-2.6, thanks.=0D
=0D
Hmmrr or not. I took an old buggy patchset. Trivial fix follows. Sorry.=
=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

