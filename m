From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: multi-machine simultaneous kernel panic in tcp_transmit_kcb
Date: Thu, 28 Oct 2010 21:42:51 +0100
Message-ID: <20101028204250.GJ15074@solarflare.com>
References: <4CC8CC0A.5000705@will.to>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Doug Hughes <doug@will.to>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:10988 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933688Ab0J1Um5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 16:42:57 -0400
Content-Disposition: inline
In-Reply-To: <4CC8CC0A.5000705@will.to>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doug Hughes wrote:
> 3 machines within 1 minute of each other (odd, by itself, but not the 
> root of the question).
> 
> 2 of this:
> 2.6.18-164.15.1.el5 #1 SMP Wed Mar 17 11:30:06 EDT 2010 x86_64 x86_64 
> x86_64 GNU/Linux
> (I have a screen shot on the kvm)
> all Cent 5.4
[...]
 
Please don't ask netdev to support an old distribution kernel.  Try
asking on CentOS support forums or buy support from Red Hat.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
