From: Marcus Better <marcus@better.se>
Subject: Re: [Bugme-new] [Bug 10327] New: keyboard stops responding after
 "ifdown eth0"
Date: Tue, 25 Mar 2008 22:43:56 +0100
Message-ID: <47E9721C.2000306@better.se>
References: <bug-10327-10286@http.bugzilla.kernel.org/> <20080325143941.300d415f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, linux-kernel@vger.kernel.org,
	linux-input@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from public.bindows.net ([66.135.40.169]:53506 "EHLO
	public.bindows.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761470AbYCYWEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 18:04:22 -0400
In-Reply-To: <20080325143941.300d415f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> Perhaps you could try
> 
> 	ifdown eth0 ; sleep 5 ; ifup eth0

Will try. There is also a Debian bug report of the same or a similar 
problem with kernels from 2.6.18:

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=415147

