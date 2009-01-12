From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] NET: fix wrong English expression in comments
Date: Mon, 12 Jan 2009 01:39:18 +0000
Message-ID: <1231724358.2674.13.camel@hashbaz.i.decadent.org.uk>
References: <496a3c51.09876e0a.03fe.7e80@mx.google.com>
	 <496A9753.80802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Qinghuang Feng <qhfeng.kernel@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:4120 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752071AbZALBeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 20:34:13 -0500
In-Reply-To: <496A9753.80802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-01-12 at 09:05 +0800, Li Zefan wrote:
> > @@ -103,7 +103,7 @@ struct inet_bind_bucket;
> >  struct inet_timewait_sock {
> >  	/*
> >  	 * Now struct sock also uses sock_common, so please just
> > -	 * don't add nothing before this first member (__tw_common) --acme
> > +	 * don't add anything before this first member (__tw_common) --acme
> 
> They are the same meaning...

A double-negative can be an informal way of reinforcing a negative, but
can sometimes mean the positive.  So this change would remove a minor
ambiguity.  However I think it should be clear that it is not compulsory
to add new members to the structure. ;-)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


