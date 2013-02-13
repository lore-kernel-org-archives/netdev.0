From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v5 05/11] sch: make htb_rate_cfg and functions
 around that generic
Date: Tue, 12 Feb 2013 19:00:32 -0500 (EST)
Message-ID: <20130212.190032.473881700486277733.davem@davemloft.net>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	<1360663929-1023-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759242Ab3BMAAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 19:00:34 -0500
In-Reply-To: <1360663929-1023-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 12 Feb 2013 11:12:03 +0100

> As it is going to be used in tbf as well, push these to generic code.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
