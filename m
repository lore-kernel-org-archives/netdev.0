From: Marcus Better <marcus@better.se>
Subject: Re: [Bug 10327] New: keyboard stops responding after "ifdown eth0"
Date: Fri, 11 Apr 2008 13:12:01 +0200
Message-ID: <47FF4781.3040506@better.se>
References: <bug-10327-10286@http.bugzilla.kernel.org/>	<20080325143941.300d415f.akpm@linux-foundation.org>	<47E9721C.2000306@better.se>	<47E99258.3060005@s5r6.in-berlin.de>	<20080325171608.509f4ca7.akpm@linux-foundation.org>	<47EA152C.6000008@better.se> <20080326102931.484285f3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stefanr@s5r6.in-berlin.de, bugme-daemon@bugzilla.kernel.org,
	linux-kernel@vger.kernel.org, linux-input@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from public.bindows.net ([66.135.40.169]:41044 "EHLO
	public.bindows.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759323AbYDKLMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 07:12:15 -0400
In-Reply-To: <20080326102931.484285f3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> I'd suggest running (and perhaps suitably modifying) this:

This doesn't seem to help, it freezes without printing anything, and 
there is nothing in the logs either.
