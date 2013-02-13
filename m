From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v5 03/11] htb: remove pointless first
 initialization of buffer and cbuffer
Date: Tue, 12 Feb 2013 19:00:17 -0500 (EST)
Message-ID: <20130212.190017.1831835981289433321.davem@davemloft.net>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	<1360663929-1023-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759179Ab3BMAAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 19:00:19 -0500
In-Reply-To: <1360663929-1023-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 12 Feb 2013 11:12:01 +0100

> these are initialized correctly couple of lines later in the function.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
