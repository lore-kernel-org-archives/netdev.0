From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net_sched: fix dequeuer fairness
Date: Sun, 26 Jun 2011 22:18:37 +0100
Message-ID: <1309123118.3093.1501.camel@localhost>
References: <1309097254.5134.24.camel@mojatatu>
	 <1309100994.2532.35.camel@edumazet-laptop>
	 <1309102334.5134.31.camel@mojatatu>  <1309104215.5134.37.camel@mojatatu>
	 <1309105599.2532.50.camel@edumazet-laptop>
	 <1309105745.5134.54.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3367 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639Ab1FZVSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 17:18:42 -0400
In-Reply-To: <1309105745.5134.54.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-06-26 at 12:29 -0400, jamal wrote:
> On Sun, 2011-06-26 at 18:26 +0200, Eric Dumazet wrote:
> 
> > Difficult to discuss about your patch because you didnt inline it :-(
> 
> Evolution messes up with the whitespaces when i do that.
[...]

It works for me.  Compose as plain text, and select 'Preformatted'
before inserting the file.  Or use 'git imap-send' to put the message in
your drafts folder and then edit that.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

