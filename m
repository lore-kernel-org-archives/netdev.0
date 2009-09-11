From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net_sched 07/07: add classful multiqueue dummy scheduler
Date: Sat, 12 Sep 2009 00:21:22 +0200
Message-ID: <20090911222122.GA6826@ami.dom.local>
References: <20090909195238.GA3043@ami.dom.local>
 <4AA8E2FB.3040809@trash.net>
 <20090911213812.GA3965@ami.dom.local>
 <20090911.151039.40579542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:57948 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbZIKWVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 18:21:33 -0400
Received: by fxm17 with SMTP id 17so1105752fxm.37
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2009 15:21:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090911.151039.40579542.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2009 at 03:10:39PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 11 Sep 2009 23:38:13 +0200
> 
> > On Thu, Sep 10, 2009 at 01:28:59PM +0200, Patrick McHardy wrote:
> > ...
> >> I'll remove the misleading (and unnecessary) line of code, thanks Jarek.
> > 
> > Btw, I guess David owes you one classful(!) dummy(?) scheduler...
> 
> Did I forget to add the sch_mq.c file to the tree?  What are
> you saying? :-)

commit 6ec1c69a8f6492fd25722f4762721921da074c12
Author: David S. Miller <davem@davemloft.net>
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ?! ;-)

Jarek P.
