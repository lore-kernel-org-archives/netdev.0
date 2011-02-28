From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy and
 source mac selection mode
Date: Mon, 28 Feb 2011 13:09:59 +0300
Message-ID: <4D6B7477.305@yandex-team.ru>
References: <20110216191341.GA14920@yandex-team.ru> <20110227.160823.35047612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from archeopterix.yandex.ru ([93.158.136.52]:24260 "EHLO
	archeopterix.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734Ab1B1KIn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 05:08:43 -0500
In-Reply-To: <20110227.160823.35047612.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, thank you for reply.
Actually this is second version of patch discussed previously in=20
http://patchwork.ozlabs.org/patch/78994/
I've remade that patch into current version=20
(patchwork.ozlabs.org/patch/83389/) in the way Jay suggested.
Jay, can you please comment on patch I've remade, please?

On 02/28/2011 03:08 AM, David Miller wrote:
> From: "Oleg V. Ukhno"<olegu@yandex-team.ru>
> Date: Wed, 16 Feb 2011 22:13:41 +0300
>
>>
> Can we get some feedback on this patch from bonding folks?
>
> I'm not applying it blinding without at least one bonding developer
> saying it at least looks ok.
>
> Thanks.
>


--=20
=D0=A1 =D1=83=D0=B2=D0=B0=D0=B6=D0=B5=D0=BD=D0=B8=D0=B5=D0=BC,
=D1=80=D1=83=D0=BA=D0=BE=D0=B2=D0=BE=D0=B4=D0=B8=D1=82=D0=B5=D0=BB=D1=8C=
 =D1=81=D0=BB=D1=83=D0=B6=D0=B1=D1=8B
=D1=8D=D0=BA=D1=81=D0=BF=D0=BB=D1=83=D0=B0=D1=82=D0=B0=D1=86=D0=B8=D0=B8=
 =D0=BA=D0=BE=D0=BC=D0=BC=D0=B5=D1=80=D1=87=D0=B5=D1=81=D0=BA=D0=B8=D1=85=
 =D0=B8 =D1=84=D0=B8=D0=BD=D0=B0=D0=BD=D1=81=D0=BE=D0=B2=D1=8B=D1=85 =D1=
=81=D0=B5=D1=80=D0=B2=D0=B8=D1=81=D0=BE=D0=B2
=D0=9E=D0=9E=D0=9E =D0=AF=D0=BD=D0=B4=D0=B5=D0=BA=D1=81

=D0=9E=D0=BB=D0=B5=D0=B3 =D0=AE=D1=85=D0=BD=D0=BE


