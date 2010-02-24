From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH] ixgbe: convert to use netdev_for_each_mc_addr
Date: Wed, 24 Feb 2010 01:30:54 -0800
Message-ID: <9929d2391002240130p17bbc1acj74e3c8306a3f664@mail.gmail.com>
References: <20100223190505.GA2673@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f191.google.com ([209.85.216.191]:42907 "EHLO
	mail-px0-f191.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755923Ab0BXJaz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 04:30:55 -0500
Received: by pxi29 with SMTP id 29so2564933pxi.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2010 01:30:54 -0800 (PST)
In-Reply-To: <20100223190505.GA2673@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2010 at 11:05, Jiri Pirko <jpirko@redhat.com> wrote:
>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
> =C2=A0drivers/net/ixgbe/ixgbe_common.c | =C2=A0 16 +++++++---------
> =C2=A0drivers/net/ixgbe/ixgbe_common.h | =C2=A0 =C2=A05 ++---
> =C2=A0drivers/net/ixgbe/ixgbe_main.c =C2=A0 | =C2=A0 24 ++-----------=
-----------
> =C2=A0drivers/net/ixgbe/ixgbe_type.h =C2=A0 | =C2=A0 =C2=A03 +--
> =C2=A04 files changed, 12 insertions(+), 36 deletions(-)
>

Thanks Jiri, I have added the patch to my queue of ixgbe patches.

--=20
Cheers,
Jeff
