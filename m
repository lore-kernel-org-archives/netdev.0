From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver compatibility with rtl8168 [need confirm]
Date: Tue, 26 Feb 2008 21:14:41 +0100
Message-ID: <20080226201441.GA15796@electric-eye.fr.zoreil.com>
References: <a37929f0802251403q36ef6306wa30298dbded0d8ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Miroslav Kratochvil <exa.exa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58170 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761876AbYBZUcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 15:32:54 -0500
Content-Disposition: inline
In-Reply-To: <a37929f0802251403q36ef6306wa30298dbded0d8ed@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miroslav Kratochvil <exa.exa@gmail.com> :
[...]
> Many users who have onboard Realtek 8168 network controllers in
> combination with nVidia hardware (mostly nVidia graphic card and/or
> nForce motherboard (MCP5x) ) experience still-not-very-explained
> hangup triggered by heavy network usage which fills a tx buffer, and
> (speculation) causes race condition on irq sharing, resulting in
> absolute freeze (not oops/panic). On all affected machines I've seen
> this fix solved the problem:

Where can the reports of these users be found ?

-- 
Ueimor
