From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 14:31:31 +0800
Message-ID: <20170821063130.GA73165@cran64.bj.intel.com>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
 <20170818152601.3760aaec@griffin>
 <20170818153103.5a757abe@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "blp@ovn.org" <blp@ovn.org>, "e@erig.me" <e@erig.me>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22011 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751050AbdHUGqH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 02:46:07 -0400
Content-Disposition: inline
In-Reply-To: <20170818153103.5a757abe@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 09:31:03PM +0800, Jiri Benc wrote:
> On Fri, 18 Aug 2017 15:26:01 +0200, Jiri Benc wrote:
> > Out of time for today, will continue the review next week. Again, feel
> > free to send a new version meanwhile or wait for the rest of the
> > review, whatever works better for you.
> 
> One more thing: before you send a new version, be sure and double check
> that you addressed *all* of the feedback. In this version, you still
> have not addressed a few things I gave feedback on in the previous
> version. This wastes everyone's time.

I did check every comment you added and tried my best to fix them, maybe
you mean that hacky attr & mask code, I think that one is ok in v4, I have
used your proposal in v5 and has small change, from my perspective, they
don't have what difference :-)

> 
> It doesn't mean I'm always right, of course, but you either explain why
> I'm wrong or change the code. It's generally not acceptable to ignore
> feedback.

Will be more careful later in order that we can have a more efficient
review. Thank you so much for your great comments.

> 
> Thank you,
> 
>  Jiri
