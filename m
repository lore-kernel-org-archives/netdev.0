From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v4 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 10:29:52 +0200
Message-ID: <1491899392.31620.14.camel@sipsolutions.net>
References: <20170411065700.2623-1-johannes@sipsolutions.net>
         <20170411065700.2623-2-johannes@sipsolutions.net>
         <20170411071900.GC1976@nanopsycho>
         <1491895758.31620.4.camel@sipsolutions.net>
         <20170411081346.GD1976@nanopsycho> (sfid-20170411_101348_843690_BC897405)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48174 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751645AbdDKI34 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 04:29:56 -0400
In-Reply-To: <20170411081346.GD1976@nanopsycho> (sfid-20170411_101348_843690_BC897405)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-11 at 10:13 +0200, Jiri Pirko wrote:
> Tue, Apr 11, 2017 at 09:29:18AM CEST, johannes@sipsolutions.net
> wrote:
> > On Tue, 2017-04-11 at 09:19 +0200, Jiri Pirko wrote:
> > > 
> > > > +	NUM_NLMSGERR_ATTRS,
> > > 
> > > According to the rest of the uapi, this should be rather named:
> > > 	__NLMSGERR_ATTR_MAX
> > 
> > nl80211 uses NUM_ so I guess that's a matter of convention, but I
> > can
> > change that I guess.
> 
> Please do.

No further comments on any other parts of the patch(es)? :)

I don't want to be resending all the time, so I guess I'll wait. For
now, all code is in the nl-err branch in mac80211-next.

johannes
