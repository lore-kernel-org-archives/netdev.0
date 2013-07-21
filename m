From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next v2 1/3] net: add ndo to get id of physical port
 of the device
Date: Sun, 21 Jul 2013 16:01:28 +0100
Message-ID: <1374418888.16533.81.camel@deadeye.wl.decadent.org.uk>
References: <1374342834-10814-1-git-send-email-jiri@resnulli.us>
	 <1374342834-10814-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stephen@networkplumber.org>, <Narendra_K@Dell.com>,
	<john.r.fastabend@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30582 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755557Ab3GUPBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 11:01:32 -0400
In-Reply-To: <1374342834-10814-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-07-20 at 19:53 +0200, Jiri Pirko wrote:
> This patch adds a ndo for getting physical port of the device. Driver
> which is aware of being virtual function of some physical port should
> implement this ndo.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
