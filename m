From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] netem: missing break in ge loss generator
Date: Sat, 30 Nov 2013 12:49:55 -0500 (EST)
Message-ID: <20131130.124955.2276805847302459483.davem@davemloft.net>
References: <20131129110243.1ce4e87b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin.burri@ch.abb.com, hagen@jauu.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725Ab3K3Rt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 12:49:56 -0500
In-Reply-To: <20131129110243.1ce4e87b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 29 Nov 2013 11:02:43 -0800

> There is a missing break statement in the Gilbert Elliot loss model
> generator which makes state machine behave incorrectly.
> 
> Reported-by: Martin Burri <martin.burri@ch.abb.com
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
