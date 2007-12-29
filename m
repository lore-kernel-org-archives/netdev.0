From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Top 9 kernel oopses/warnings for the week of December 29th,
 2007
Date: Sat, 29 Dec 2007 11:52:26 -0800 (PST)
Message-ID: <alpine.LFD.0.9999.0712291147400.2778@woody.linux-foundation.org>
References: <477630CF.5070609@linux.intel.com> <alpine.LFD.0.9999.0712291116190.2778@woody.linux-foundation.org> <4776A13C.1080405@linux.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57677 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751144AbXL2Tw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 14:52:29 -0500
In-Reply-To: <4776A13C.1080405@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 29 Dec 2007, Arjan van de Ven wrote:
> 
> hmmm.. the copy in my Sent folder looks fine, as does the one in the lkml
> archive:
> http://lkml.org/lkml/2007/12/29/41
> 
> This is distinctly weird.

Ahh, it seems to be a alpine bug. Probably brought on by alpine trying to 
highlight the web addresses.

It doesn't always happen - between Rank 3 and Rank 4, you have an empty 
line, and alpine reacted correctly to that one, but the "empty" line 
between Rank 1 and Rank 2 actually contained a single TAB, and that 
apparently made alpine really confused.

So never mind. I'll make a bug-report on alpine, it wasn't a bug in your 
email.

		Linus
