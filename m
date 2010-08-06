From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [GIT] Networking
Date: Thu, 05 Aug 2010 21:58:07 -0700
Message-ID: <4C5B965F.4020109@kernel.org>
References: <20100803.203814.59697285.davem@davemloft.net> 	<AANLkTimxv1y3QJ7s+ghi1FFCcwnUVWT1n6dvT-NNN=Oo@mail.gmail.com> 	<AANLkTinU4+tcm2O_BVBFkHSdnx7JEPtM4sw_s--qdUKC@mail.gmail.com> <AANLkTi=3dVWKtgL2A=4xm_1VSk64--3Zk_fQBYUdAAn+@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:52226 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab0HFFLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 01:11:42 -0400
In-Reply-To: <AANLkTi=3dVWKtgL2A=4xm_1VSk64--3Zk_fQBYUdAAn+@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2010 07:15 PM, Linus Torvalds wrote:
> On Thu, Aug 5, 2010 at 7:04 PM, Yinghai Lu <yinghai@kernel.org> wrote=
:
>>
>>  CC      drivers/net/ixgbe/ixgbe_main.o
>> drivers/net/ixgbe/ixgbe_main.c: In function =91ixgbe_select_queue=92=
:
>> drivers/net/ixgbe/ixgbe_main.c:6159: error: =91struct ixgbe_fcoe=92 =
has no member named =91up=92
>=20
> Hmm. You must have some other version of that file than I do. Line
> 6159 is in ixgbe_init_module() in my source tree.
>=20

http://patchwork.ozlabs.org/patch/60777/

Yinghai
