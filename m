From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Sat, 8 Mar 2008 11:52:50 +0100
Message-ID: <20080308105250.GB3301@ami.dom.local>
References: <20080306175629.GA2876@ami.dom.local> <1204836523.4457.103.camel@localhost> <20080306214000.GC2876@ami.dom.local> <1204846839.4431.23.camel@localhost> <20080307075113.GA3912@ff.dom.local> <1204898002.4431.99.camel@localhost> <20080308084628.GA2749@ami.dom.local> <20080308085854.GB2749@ami.dom.local> <20080308101540.M65133@visp.net.lb> <20080308104322.GA3301@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:5851 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbYCHKrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 05:47:31 -0500
Received: by ug-out-1314.google.com with SMTP id z38so4571073ugc.16
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2008 02:47:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080308104322.GA3301@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 08, 2008 at 11:43:22AM +0100, Jarek Poplawski wrote:
...
> ...Hmm... the same day I sent to you "take 2" of my patch which was more
> complete (lockdep_set_class for ingress_lock added). Could you try this?
> It still could be not enough, and something similar is needed for
> tcfc_lock in act_mirred, but I'd like to see a report after this patch
> first.

...Hmm#2... or maybe it doesn't matter? I'll try to send you today
this additional act_mirred patch.

Jarek P.
