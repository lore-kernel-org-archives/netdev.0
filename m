From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] netem: fix gemodel loss generator
Date: Sat, 30 Nov 2013 12:50:05 -0500 (EST)
Message-ID: <20131130.125005.1257261353099186094.davem@davemloft.net>
References: <20131129110243.1ce4e87b@nehalam.linuxnetplumber.net>
	<20131129110426.5aa54569@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin.burri@ch.abb.com, hagen@jauu.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab3K3RuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 12:50:07 -0500
In-Reply-To: <20131129110426.5aa54569@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 29 Nov 2013 11:04:26 -0800

> Patch from developers of the alternative loss models, downloaded from:
>    http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG
> 
>  "in case 2, of the switch we change the direction of the inequality to
>   net_random()>clg->a3, because clg->a3 is h in the GE model and when h
>   is 0 all packets will be lost."
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
