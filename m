From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tainted warnings with tcp splicing in 3.7.1
Date: Thu, 10 Jan 2013 08:20:25 -0800
Message-ID: <1357834825.27446.2205.camel@edumazet-glaptop>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan>
	 <1357750898.27446.33.camel@edumazet-glaptop>
	 <1357751372.27446.40.camel@edumazet-glaptop>
	 <1357801149.27446.1142.camel@edumazet-glaptop>
	 <20130110072136.GK9943@1wt.eu>
	 <1357831787.27446.2168.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christian Becker <c.becker@traviangames.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>, Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:63766 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610Ab3AJQU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 11:20:29 -0500
Received: by mail-pb0-f48.google.com with SMTP id rq13so389033pbb.21
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 08:20:28 -0800 (PST)
In-Reply-To: <1357831787.27446.2168.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-10 at 07:29 -0800, Eric Dumazet wrote:
> On Thu, 2013-01-10 at 08:21 +0100, Willy Tarreau wrote:
> 
> > FWIW, I tested your patch here and did not notice any regression
> > compared to last week-end tests, at various MTU size combinations.
> > 
> 
> Thanks Willy

I also want to thanks Rick, as the latest netperf has splice() support.

Thanks Rick !
