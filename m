From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/9 net-next] rhashtable: Per bucket locks & deferred
 table resizing
Date: Mon, 15 Dec 2014 16:27:30 +0000
Message-ID: <20141215162730.GA30121@casper.infradead.org>
References: <cover.1418647641.git.tgraf@suug.ch>
 <20141215130050.GA9628@casper.infradead.org>
 <20141215.111838.992055066540772910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, edumazet@google.com,
	john.r.fastabend@intel.com, josh@joshtriplett.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40176 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbaLOQ1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 11:27:34 -0500
Content-Disposition: inline
In-Reply-To: <20141215.111838.992055066540772910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/14 at 11:18am, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Mon, 15 Dec 2014 13:00:50 +0000
> 
> > Meant for "net-next". Apologies for the missing prefix.
> 
> Which is not open for submission right now, please resubmit when it is
> re-openned.

Will do. I wanted to expose it as soon as it's done as Herbert is
working on rehashing and I wanted him and everyone else to be aware
of this.
