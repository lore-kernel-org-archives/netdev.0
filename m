From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: Avoid crashing in ip_error
Date: Fri, 22 May 2015 15:05:42 -0400 (EDT)
Message-ID: <20150522.150542.1824059270184099624.davem@davemloft.net>
References: <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
	<20150522.142447.1048811620866120127.davem@davemloft.net>
	<379cd5bb2c3e9b3041c41d758c833ff0@vittgam.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, security@kernel.org,
	greg@kroah.com, luto@amacapital.net, w@1wt.eu
To: linuxbugs@vittgam.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756048AbbEVTFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 15:05:45 -0400
In-Reply-To: <379cd5bb2c3e9b3041c41d758c833ff0@vittgam.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vittorio G (VittGam)" <linuxbugs@vittgam.net>
Date: Fri, 22 May 2015 20:48:38 +0200

> Il 22.05.2015 20:24 David Miller ha scritto:
>> Looks good, applied and queued up for -stable, thanks!
> 
> That's great!
> 
> I think this should also be backported up to Linux mainline 3.10,
> since
> the original commit that introduced the bug first appeared in 3.6.

Ummm, that's what "queued up for -stable" means.  It means that I'll
submit it to -stable for all active -stable series.
