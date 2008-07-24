From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [build failure] hp-plus.c: (.text+0xd7c1a): undefined reference
 to `ei_close'
Date: Thu, 24 Jul 2008 20:54:41 +0100
Message-ID: <20080724205441.3465f4d4@lxorguk.ukuu.org.uk>
References: <20080721.233512.128618365.anemo@mba.ocn.ne.jp>
	<20080721191519.GA15843@elte.hu>
	<20080721214258.787a67ca@lxorguk.ukuu.org.uk>
	<20080722072334.GA25241@elte.hu>
	<48865899.3030209@garzik.org>
	<20080723104520.GA20672@elte.hu>
	<20080724052603.GA8744@elte.hu>
	<20080724100615.764bac36@lxorguk.ukuu.org.uk>
	<4888D631.8040401@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Atsushi Nemoto <anemo@mba.ocn.ne.jp>,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:43938 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751610AbYGXUMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 16:12:46 -0400
In-Reply-To: <4888D631.8040401@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> My apologies.  FWIW, from my point of view the same patch(es) kept 
> getting fixed and updated and going around in circles, so I kept 
> waiting.  Since it was was a net-next issue (until now), I lowered the 
> priority and waited to let you guys (you, Andrew, Randy mainly) sort 
> things out.
> 
> So far the only remaining patch I have outstanding and needing to be 
> applied is from Atsushi-san via Ingo (message id 
> <20080723104520.GA20672@elte.hu>)...  is that the last of it?

I've got a reference tree that I will regenerate and diff against the
upstream GIT tree to check. It looks like some of the ei_ to eip_ changes
have gone for a walk.

Its on my TODO list and now IT821x is working again the panic mode stuff
is over I hope

Alan
