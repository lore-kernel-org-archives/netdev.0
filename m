From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 5 Aug 2010 19:15:04 -0700
Message-ID: <AANLkTi=3dVWKtgL2A=4xm_1VSk64--3Zk_fQBYUdAAn+@mail.gmail.com>
References: <20100803.203814.59697285.davem@davemloft.net>
	<AANLkTimxv1y3QJ7s+ghi1FFCcwnUVWT1n6dvT-NNN=Oo@mail.gmail.com>
	<AANLkTinU4+tcm2O_BVBFkHSdnx7JEPtM4sw_s--qdUKC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45375 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760380Ab0HFCPx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 22:15:53 -0400
In-Reply-To: <AANLkTinU4+tcm2O_BVBFkHSdnx7JEPtM4sw_s--qdUKC@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 5, 2010 at 7:04 PM, Yinghai Lu <yinghai@kernel.org> wrote:
>
> =A0CC =A0 =A0 =A0drivers/net/ixgbe/ixgbe_main.o
> drivers/net/ixgbe/ixgbe_main.c: In function =91ixgbe_select_queue=92:
> drivers/net/ixgbe/ixgbe_main.c:6159: error: =91struct ixgbe_fcoe=92 h=
as no member named =91up=92

Hmm. You must have some other version of that file than I do. Line
6159 is in ixgbe_init_module() in my source tree.

                 Linus
