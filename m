From: Alexey Toptygin <alexeyt@freeshell.org>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 3 May 2006 12:15:30 +0000 (UTC)
Message-ID: <Pine.NEB.4.62.0605031206040.18261@otaku.freeshell.org>
References: <E1FbBPy-0007Iu-00@gondolin.me.apana.org.au> <4458A6C1.90103@corky.net>
 <20060503115653.GA1353@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Just Marc <marc@corky.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.freeshell.ORG ([192.94.73.18]:50631 "EHLO sdf.lonestar.org")
	by vger.kernel.org with ESMTP id S965175AbWECMQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 08:16:04 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060503115653.GA1353@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 May 2006, Herbert Xu wrote:

> Can you take a tcpdump of the TCP sessions involving those IPs and
> then show me the sections that occur when those messages are triggered?

I'm curious, how would you do this without filling the disk? With a script 
that starts tcpdump to a ring in the background, waits for the offending 
log entry to appear and then kills tcpdump?

 			Alexey
