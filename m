From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sock: only define socket limit if mem cgroup
 configured
Date: Fri, 22 Feb 2013 15:14:11 -0500 (EST)
Message-ID: <20130222.151411.1467825322167742622.davem@davemloft.net>
References: <20130222095910.3ce8074b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757009Ab3BVUOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 15:14:12 -0500
In-Reply-To: <20130222095910.3ce8074b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 22 Feb 2013 09:59:10 -0800

> The mem cgroup socket limit is only used if the config option is
> enabled. Found with sparse
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
