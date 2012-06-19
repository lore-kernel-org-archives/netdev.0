From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Mon, 18 Jun 2012 21:03:26 -0700 (PDT)
Message-ID: <a22edf13-1bf5-49fb-8ebe-05054f68c129@tahiti.vyatta.com>
References: <20120618.194016.2282814982594761206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39253 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742Ab2FSED1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 00:03:27 -0400
In-Reply-To: <20120618.194016.2282814982594761206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> You know you want it.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

David, I understand it, Eric understands it, and maybe one or
two others. But on the principal of what is "good for the goose
is good for the gander", you really need to provide a reasonable
change log entry. Just because you are the network maintainer
doesn't mean you get to skip all the documented rules about submitting
patches.
