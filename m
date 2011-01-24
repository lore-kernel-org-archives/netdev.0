From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/4][pull request] Intel Wired LAN Driver Updates
Date: Mon, 24 Jan 2011 00:19:30 -0800
Message-ID: <AANLkTikmt1BsuLmw+6Lv_trPfRzHYdjWY-61DPv_3T7y@mail.gmail.com>
References: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:54398 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832Ab1AXITc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 03:19:32 -0500
Received: by iwn9 with SMTP id 9so3727125iwn.19
        for <netdev@vger.kernel.org>; Mon, 24 Jan 2011 00:19:32 -0800 (PST)
In-Reply-To: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 22, 2011 at 03:56, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> The following series contains cleanups for e1000e and addition suppor=
t
> for the i340 adapter in igb.
>
> The following are changes since commit bb134d2298b49f50cf6d9388410fba=
96272905dc:
> =C2=A0net: netif_setup_tc() is static
>
> and are available in the git repository at:
> =C2=A0master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2=
=2E6 master
>
> Bruce Allan (2):
> =C2=A0e1000e: reduce scope of some variables, remove unnecessary ones
> =C2=A0e1000e: Use kmemdup rather than duplicating its implementation
>
> Carolyn Wyborny (1):
> =C2=A0igb: Add support for i340 Quad Port Fiber Adapter
>
> Jeff Kirsher (1):
> =C2=A0e1000e: convert to stats64
>

I have updated my tree to include Flavio's Signed-off-by on the followi=
ng patch:

e1000e: convert to stats64

--=20
Cheers,
Jeff
