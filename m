From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sched action: make local function static
Date: Thu, 02 Jan 2014 03:32:29 -0500 (EST)
Message-ID: <20140102.033229.1282489645522200955.davem@davemloft.net>
References: <20131231115400.6e85bd34@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbaABIca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 03:32:30 -0500
In-Reply-To: <20131231115400.6e85bd34@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 31 Dec 2013 11:54:00 -0800

> No need to export functions only used in one file.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
