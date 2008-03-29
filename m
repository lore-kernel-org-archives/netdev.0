From: Oliver Martin <oliver.martin@student.tuwien.ac.at>
Subject: Re: [PATCH] Re: ep93xx_eth PHY problems
Date: Sat, 29 Mar 2008 19:13:07 +0100
Message-ID: <20080329191307.665f2056@ors>
References: <47CD4857.2060406@student.tuwien.ac.at>
	<20080321202202.129c1239@ors>
	<47E9D438.4090206@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hvr@gnu.org, buytenh@wantstofly.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:45017 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024AbYC2SNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 14:13:42 -0400
Received: by fg-out-1718.google.com with SMTP id l27so894831fgb.17
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2008 11:13:41 -0700 (PDT)
In-Reply-To: <47E9D438.4090206@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Wed, 26 Mar 2008 00:42:32 -0400 schrieb Jeff Garzik:
> 
> ACKs from Lennert, others?
> 
> I don't know enough about the hardware to say...
> 
> Seems straightforward to me?
> 
> 2.6.25 or 2.6.26 material?

It depends on Herbert Valerio Riedel's ep93xx_eth phylib conversion,
which isn't in 2.6.25-rc7 (but received an ACK from Lennert some
weeks ago). I guess it should go in whenever that is merged.

> 
> Any more testing results?
> 
Sorry, I haven't had much time recently, so I haven't further
investigated the autoneg off issue. I've seen it work fine sometimes,
so it's either some very weird bug or something totally unrelated.

-- 
Oliver
