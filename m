From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH iproute/master 0/3] lost mpls ip tunnel patches
Date: Wed, 14 Jun 2017 10:33:22 -0700
Message-ID: <20170614173322.GC2368@templeofstupid.com>
References: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
 <20170614102451.42b301bd@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krister Johansen <kjlx@templeofstupid.com>, netdev@vger.kernel.org,
        simon.horman@netronome.com, dsahern@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:36370 "EHLO
        homiemail-a68.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752057AbdFNRdV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:33:21 -0400
Received: from homiemail-a68.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a68.g.dreamhost.com (Postfix) with ESMTP id DF34048000B36
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:33:20 -0700 (PDT)
Received: from kmjvbox (c-174-62-91-145.hsd1.ca.comcast.net [174.62.91.145])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a68.g.dreamhost.com (Postfix) with ESMTPSA id C702248000B2A
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:33:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170614102451.42b301bd@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 14, 2017 at 10:24:51AM -0700, Stephen Hemminger wrote:
> On Fri,  9 Jun 2017 18:31:29 -0700
> Krister Johansen <kjlx@templeofstupid.com> wrote:
> 
> > Hi Stephen,
> > I'm a bit unsure of the decorum in this particular situation. Kernel
> > support for mpls/ip tunnels was integrated back in July of 2016.  At the
> > time, the author of that feature sent out a RFC patch for the iproute
> > support but never followed up on subsequent code review comments.
> > 
> > The kernel support got merged, but the iproute support never made it in.
> > I wanted to run some tests with these features.  In the process, I
> > tracked down the author's original patches, merged them into current
> > iproute, and attempted to address the comments from code reviewers.
> >
> 
> In order to get merged, an RFC message should be followed by a final
> non RFC version. I think you will find the original's were marked
> in patchwork as RFC.

Yes, absolutely true.  I was just unsure of the protocol for getting
these merged when I'm not the original author.  Trying to ensure that
credit is given where it is due, and I'm following the appropriate
procedures.

Thanks,

-K
