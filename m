From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Top 9 kernel oopses/warnings for the week of December 29th, 2007
Date: Sat, 29 Dec 2007 22:53:03 +0100 (CET)
Message-ID: <Pine.LNX.4.62.0712292252040.2528@wlug.westbo.se>
References: <477630CF.5070609@linux.intel.com>
 <alpine.LFD.0.9999.0712291116190.2778@woody.linux-foundation.org>
 <4776A13C.1080405@linux.intel.com> <alpine.LFD.0.9999.0712291147400.2778@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host91-201.netintact.se ([194.153.91.201]:55165 "EHLO
	wlug.westbo.se" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbXL2WMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 17:12:10 -0500
In-Reply-To: <alpine.LFD.0.9999.0712291147400.2778@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Dec 2007, Linus Torvalds wrote:

> Ahh, it seems to be a alpine bug. Probably brought on by alpine trying to
> highlight the web addresses.
>
> It doesn't always happen - between Rank 3 and Rank 4, you have an empty
> line, and alpine reacted correctly to that one, but the "empty" line
> between Rank 1 and Rank 2 actually contained a single TAB, and that
> apparently made alpine really confused.
>
> So never mind. I'll make a bug-report on alpine, it wasn't a bug in your
> email.

FYI, exactly the same thing happens with pine.

/Martin
