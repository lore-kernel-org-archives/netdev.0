From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPsec workshop/BoF at netdev1.1?
Date: Tue, 8 Dec 2015 12:30:02 +0100
Message-ID: <20151208113002.GJ14008@secunet.com>
References: <20151207120054.GI14008@secunet.com>
 <1449505201.25029.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56091 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755401AbbLHLaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 06:30:07 -0500
Content-Disposition: inline
In-Reply-To: <1449505201.25029.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 07, 2015 at 08:20:01AM -0800, Eric Dumazet wrote:
> On Mon, 2015-12-07 at 13:00 +0100, Steffen Klassert wrote:
> > Is there any interest in doing an IPsec workshop/BoF at netdev1.1?
> > 
> > This mail is to probe if we can gather enough discussion topics to run
> > such a workshop/BoF. So if someone is interested to attend and/or has a
> > related discussion topic, please let me know.
> > 
> > My current topics:
> > 
> > - Adding a software GRO/GSO codepath for IPsec. I have working example code,
> >   a RFC version could be ready before the netdev conference.
> 
> 
> - Remove rwlock usage (xfrm_policy_lock) from fast path and szitch to
> RCU ?

Good point. I add it to the topic list, thanks!
