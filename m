From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] netem: fix loss 4 state model
Date: Sat, 30 Nov 2013 12:50:00 -0500 (EST)
Message-ID: <20131130.125000.997911519772152060.davem@davemloft.net>
References: <20131129110243.1ce4e87b@nehalam.linuxnetplumber.net>
	<20131129110335.0ecaeed8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin.burri@ch.abb.com, hagen@jauu.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699Ab3K3RuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 12:50:02 -0500
In-Reply-To: <20131129110335.0ecaeed8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 29 Nov 2013 11:03:35 -0800

> Patch from developers of the alternative loss models, downloaded from:
>    http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG
> 
>  "In the case 1 of the switch statement in the if conditions we
>    need to add clg->a4 to clg->a1, according to the model."
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
