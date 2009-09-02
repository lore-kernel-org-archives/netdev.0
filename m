From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 2 Sep 2009 21:49:03 +0200
Message-ID: <20090902194903.GB3018@ami.dom.local>
References: <20090902081429.GB4878@ff.dom.local>
 <alpine.DEB.1.10.0909021311560.27987@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:63246 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbZIBTtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 15:49:16 -0400
Received: by bwz19 with SMTP id 19so988654bwz.37
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 12:49:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909021311560.27987@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 02, 2009 at 01:12:55PM -0500, Christoph Lameter wrote:
> 
> On Wed, 2 Sep 2009, Jarek Poplawski wrote:
> 
> > I think, tc should've no problem with displaying summary stats of
> > multiqueue qdiscs or even all of them separately, as mentioned by
> > Patrick. And, maybe I still miss something, but there should be
> > nothing special with tc vs. localhost either.
> 
> Ok. Can you come up with a patch? net/sched/sch_api.c can likely be
> patches with the loop logic that Eric suggested earlier.

Yes, it's nice Eric and Patrick found time to fix it most properly.
 
Jarek P.
