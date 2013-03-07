From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] team: unsyc the devices addresses when port is removed
Date: Thu, 07 Mar 2013 16:36:20 -0500 (EST)
Message-ID: <20130307.163620.1311847490309419467.davem@davemloft.net>
References: <1362679165-31203-1-git-send-email-vyasevic@redhat.com>
	<20130307183000.GA1532@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46463 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759748Ab3CGVgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:36:22 -0500
In-Reply-To: <20130307183000.GA1532@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 7 Mar 2013 19:30:00 +0100

> Thu, Mar 07, 2013 at 06:59:25PM CET, vyasevic@redhat.com wrote:
>>When a team port is removed, unsync all devices addresses that may have
>>been synched to the port devices.
> 
> 
> This is looking good to me. Thanks for spotting this bug.
> 
> Acked-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks everyone.
