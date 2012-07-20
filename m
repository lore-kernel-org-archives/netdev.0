From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 00/16]: Kill the ipv4 routing cache.
Date: Fri, 20 Jul 2012 16:09:29 +0100
Message-ID: <1342796969.2678.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120719.143403.1702333347618917729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:47398 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751144Ab2GTPJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 11:09:32 -0400
In-Reply-To: <20120719.143403.1702333347618917729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 14:34 -0700, David Miller wrote:
> The ipv4 routing cache is non-deterministic, performance wise, and is
> subject to reasonably easy to launch denial of service attacks.
[...]

This is a great explanation, but it still doesn't appear to be going
into the commit log...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
