From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 v2] network: Allow af_packet to transmit +4 bytes
 for VLAN packets.
Date: Fri, 11 Feb 2011 23:18:38 +0100
Message-ID: <1297462718.2510.10.camel@edumazet-laptop>
References: <1297452918-16993-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57058 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758168Ab1BKWSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 17:18:43 -0500
Received: by fxm20 with SMTP id 20so3218246fxm.19
        for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 14:18:41 -0800 (PST)
In-Reply-To: <1297452918-16993-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 11 f=C3=A9vrier 2011 =C3=A0 11:35 -0800, greearb@candelatec=
h.com a
=C3=A9crit :
> From: Ben Greear <greearb@candelatech.com>
>=20
> This allows user-space to send a '1500' MTU VLAN packet on a
> 1500 MTU ethernet frame.  The extra 4 bytes of a VLAN header is
> not usually charged against the MTU when other parts of the
> network stack is transmitting vlans...
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


