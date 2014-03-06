From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: fix const in options processing
Date: Thu, 06 Mar 2014 17:39:41 -0500 (EST)
Message-ID: <20140306.173941.1229272841319793823.davem@davemloft.net>
References: <20140306142017.2af2b894@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@redhat.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34252 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbaCFWjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 17:39:43 -0500
In-Reply-To: <20140306142017.2af2b894@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 6 Mar 2014 14:20:17 -0800

> This is a fixup patch to resolve issues with const from my earlier patch.
> Make all the setter functions use const on input parameter.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.
