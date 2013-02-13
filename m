From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v5 06/11] sch_api: introduce
 qdisc_watchdog_schedule_ns()
Date: Tue, 12 Feb 2013 19:00:46 -0500 (EST)
Message-ID: <20130212.190046.2226822457142908160.davem@davemloft.net>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	<1360663929-1023-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759135Ab3BMAAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 19:00:47 -0500
In-Reply-To: <1360663929-1023-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 12 Feb 2013 11:12:04 +0100

> tbf will need to schedule watchdog in ns. No need to convert it twice.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied.
