From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: PROBLEM: freeze when resuming from suspend-to-ram
Date: Sat, 17 Nov 2012 11:57:02 +0100
Message-ID: <20121117105702.GA25549@electric-eye.fr.zoreil.com>
References: <1560844.T75lq5MbC7@brinja> <20121114211115.GD14880@ge.brownhat.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: medhefgo@web.de, netdev@vger.kernel.org
To: Daniele Venzano <venza@brownhat.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57101 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab2KQLUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 06:20:20 -0500
Content-Disposition: inline
In-Reply-To: <20121114211115.GD14880@ge.brownhat.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for Cc:ing Daniele.

Daniele Venzano <venza@brownhat.org> :
> On Sun, Nov 11, 2012 at 08:47:45PM +0100, medhefgo@web.de wrote:
[...]
> The patch is big and, while by looking at it nothing jumps to my eyes as
> clearly wrong, I currently do not have access to sis900 hardware to test
> it. Francois Romieu (in CC), who did the patch, perhaps can shed some light.

Nothing here. I'll search harder but I won't mind some brute force approach
at the same time.

Jan, is it ok if I split this changeset in smaller chunks to identify
which part bugs / triggers the problem ? If so please specify a kernel
version - linusish or stable - I should work with.

-- 
Ueimor
