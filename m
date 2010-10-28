From: Bob Beers <bob.beers@gmail.com>
Subject: Re: [PATCH] via-velocity: Codestyle fixes
Date: Thu, 28 Oct 2010 10:34:03 -0400
Message-ID: <AANLkTi=t-X96a2m9kmP_j+nT=tKjyOJZBsOspuBT4TmM@mail.gmail.com>
References: <1288242011-32257-1-git-send-email-alex@wigen.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alex@wigen.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:50102 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933480Ab0J1OeE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 10:34:04 -0400
In-Reply-To: <1288242011-32257-1-git-send-email-alex@wigen.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 1:00 AM,  <alex@wigen.net> wrote:
> From: Alexander Wigen <alex@wigen.net>

> =A0static void mac_wol_reset(struct mac_regs __iomem *regs)
> @@ -342,7 +342,7 @@ VELOCITY_PARAM(ValPktLen, "Receiving or Drop inva=
lid 802.3 frame");
> =A0 =A01: Wake up if link status is on/off.
> =A0 =A02: Wake up if recevied an arp packet.
> =A0 =A04: Wake up if recevied any unicast packet.
> - =A0 Those value can be sumed up to support more than one option.
> + =A0 Those value can be summed up to support more than one option.
> =A0*/
> =A0VELOCITY_PARAM(wol_opts, "Wake On Lan options");
>

my $.02 ...

s/recevied/receive/ x2

s/These values can be summed/Those value can be summed up/

-Bob Beers
