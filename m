From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] e100: Support receiving Ethernet FCS.
Date: Fri, 17 Jun 2011 18:47:11 -0700
Message-ID: <BANLkTi=_sre9=G_iDnTdjV+jgisR6c86Zg@mail.gmail.com>
References: <1308339615-5866-1-git-send-email-greearb@candelatech.com>
	<1308339615-5866-3-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35507 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220Ab1FRBrM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 21:47:12 -0400
Received: by fxm17 with SMTP id 17so49493fxm.19
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 18:47:11 -0700 (PDT)
In-Reply-To: <1308339615-5866-3-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2011 at 12:40,  <greearb@candelatech.com> wrote:
> From: Ben Greear <greearb@candelatech.com>
>
> Helps when sniffing packets.
>
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 e336c79... 647d8c6... M =C2=A0drivers/net/e100.c
> =C2=A0drivers/net/e100.c | =C2=A0 35 ++++++++++++++++++++++++++++++++=
---
> =C2=A01 files changed, 32 insertions(+), 3 deletions(-)
>

The patch looks fine to me.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=20
Cheers,
Jeff
