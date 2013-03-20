From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sh_eth: check TSU registers ioremap() error
Date: Wed, 20 Mar 2013 12:23:52 -0400 (EDT)
Message-ID: <20130320.122352.1542334118729356561.davem@davemloft.net>
References: <201303200241.33137.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932536Ab3CTQXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:23:54 -0400
In-Reply-To: <201303200241.33137.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 20 Mar 2013 02:41:32 +0300

> One must check the result of ioremap() -- in this case it prevents potential
> kernel oops when initializing TSU registers further on...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied and queued up for -stable.
