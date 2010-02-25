From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH] ixgbevf: convert to use netdev_for_each_mc_addr
Date: Thu, 25 Feb 2010 15:55:24 -0800
Message-ID: <9929d2391002251555l7314e086n279316e4c80b95c7@mail.gmail.com>
References: <20100223190644.GB2673@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:50974 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759318Ab0BYXz0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 18:55:26 -0500
Received: by pzk32 with SMTP id 32so1075387pzk.4
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 15:55:24 -0800 (PST)
In-Reply-To: <20100223190644.GB2673@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2010 at 11:06, Jiri Pirko <jpirko@redhat.com> wrote:
>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
> =C2=A0drivers/net/ixgbevf/ixgbevf_main.c | =C2=A0 24 +---------------=
--------
> =C2=A0drivers/net/ixgbevf/vf.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0 24 ++++++++++++------------
> =C2=A0drivers/net/ixgbevf/vf.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0 =C2=A04 ++--
> =C2=A03 files changed, 15 insertions(+), 37 deletions(-)
>

Thanks Jiri, I have added the patch to my queue of patches.

--=20
Cheers,
Jeff
