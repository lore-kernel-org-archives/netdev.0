From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next-2.6 PATCH] ixgbe: convert to use
 netdev_for_each_mc_addr
Date: Thu, 11 Mar 2010 11:08:09 +0100
Message-ID: <20100311100809.GB3054@psychotron.lab.eng.brq.redhat.com>
References: <20100223190505.GA2673@psychotron.redhat.com>
 <9929d2391002240130p17bbc1acj74e3c8306a3f664@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17466 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756548Ab0CKKIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 05:08:13 -0500
Content-Disposition: inline
In-Reply-To: <9929d2391002240130p17bbc1acj74e3c8306a3f664@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 24, 2010 at 10:30:54AM CET, jeffrey.t.kirsher@intel.com wrote:
>On Tue, Feb 23, 2010 at 11:05, Jiri Pirko <jpirko@redhat.com> wrote:
>>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> ---
>> =A0drivers/net/ixgbe/ixgbe_common.c | =A0 16 +++++++---------
>> =A0drivers/net/ixgbe/ixgbe_common.h | =A0 =A05 ++---
>> =A0drivers/net/ixgbe/ixgbe_main.c =A0 | =A0 24 ++-------------------=
---
>> =A0drivers/net/ixgbe/ixgbe_type.h =A0 | =A0 =A03 +--
>> =A04 files changed, 12 insertions(+), 36 deletions(-)
>>
>
>Thanks Jiri, I have added the patch to my queue of ixgbe patches.

Hi Jeff,

when do you think this and ixgbevf bits will be merged into net-next-2.=
6?

Thanks a lot.

Jirka
>
>--=20
>Cheers,
>Jeff
