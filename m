From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] dccp: make local variable static
Date: Sat, 04 Jan 2014 20:20:24 -0500 (EST)
Message-ID: <20140104.202024.920647175286354140.davem@davemloft.net>
References: <20140104134629.6658ab1c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbaAEBU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 20:20:26 -0500
In-Reply-To: <20140104134629.6658ab1c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 4 Jan 2014 13:46:29 -0800

> Make DCCP module config variable static, only used in one file.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
