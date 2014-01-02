From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: make more functions static
Date: Wed, 01 Jan 2014 23:44:23 -0500 (EST)
Message-ID: <20140101.234423.62836700580109559.davem@davemloft.net>
References: <20131230104341.3e7be183@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, fubar@us.ibm.com, vfalico@redhat.com,
	netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbaABEoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 23:44:25 -0500
In-Reply-To: <20131230104341.3e7be183@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 30 Dec 2013 10:43:41 -0800

> More functions in bonding that can be declared static because
> they are only used in one file.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
