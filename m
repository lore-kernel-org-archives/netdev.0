From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] socket: cleanups
Date: Fri, 03 Jan 2014 20:56:11 -0500 (EST)
Message-ID: <20140103.205611.1196976792210592341.davem@davemloft.net>
References: <20140103091714.47b1867c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35750 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754271AbaADB4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 20:56:13 -0500
In-Reply-To: <20140103091714.47b1867c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 3 Jan 2014 09:17:14 -0800

> Namespace related cleaning
> 
>  * make cred_to_ucred static
>  * remove unused sock_rmalloc function
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
