From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rocker: call correct unregister function on error
Date: Tue, 23 Jun 2015 07:13:08 -0700 (PDT)
Message-ID: <20150623.071308.1703584821344882509.davem@davemloft.net>
References: <1435045930-12130-1-git-send-email-gilad@benyossef.com>
	<20150623080140.GA2303@nanopsycho.ki.iif.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gilad@benyossef.com, sfeldma@gmail.com, netdev@vger.kernel.org,
	giladb@ezchip.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933331AbbFWOBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 10:01:18 -0400
In-Reply-To: <20150623080140.GA2303@nanopsycho.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 23 Jun 2015 10:01:40 +0200

> Tue, Jun 23, 2015 at 09:52:10AM CEST, gilad@benyossef.com wrote:
>>Use the correct unregister function matching the register
>>function on the error path.
>>
>>Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
>>CC: Gilad Ben-Yossef <giladb@ezchip.com>
>>CC: Scott Feldman <sfeldma@gmail.com>
>>CC: Jiri Pirko <jiri@resnulli.us>
> 
> Fixes: c1beeef7a32a791a ("rocker: implement IPv4 fib offloading")
> Acked-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks everyone.
