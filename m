From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnad: code cleanup
Date: Thu, 16 Jan 2014 16:23:17 -0800 (PST)
Message-ID: <20140116.162317.2216687545785900839.davem@davemloft.net>
References: <20140115082421.5d2fdfc3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbaAQAXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:23:18 -0500
In-Reply-To: <20140115082421.5d2fdfc3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 15 Jan 2014 08:24:21 -0800

> Use 'make namespacecheck' to code that could be declared static.
> After that remove code that is not being used.
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
