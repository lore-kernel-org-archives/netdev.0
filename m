From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v7 02/10] ss: created formatters for json and hr
Date: Wed, 28 Oct 2015 09:28:15 +0100
Message-ID: <20151028082815.GO26876@orbit.nwl.cc>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net>
 <20150923162650.148fe95b@urahara>
 <bc9cacb94de24857a7d9e13960bfae56@HQ1WP-EXMB11.corp.brocade.com>
 <20150924151630.28129cdb@urahara>
 <5604E357.9000802@gmx.net>
 <56308253.2060608@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"edumazet@google.com" <edumazet@google.com>
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:46177 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932533AbbJ1I2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2015 04:28:17 -0400
Content-Disposition: inline
In-Reply-To: <56308253.2060608@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2015 at 09:07:47AM +0100, Matthias Tafelmeier wrote:
> 
> >
> > Well, then we should wait for another voice aimed at the complexity of
> > the patchset before amending and resending me the patchset.
> >
> >
> 
> Well, I perceive that after Sutter has taken over the maintenance
> responsibilitiy and answered accordingly that the outstanding
> resentments as resolved.

I did not take over maintenance responsibility (whatever that means to
you precisely). I merely reviewed the patches, focussing on the
technical aspects of both implementation and patch management.

Regarding the concept itself, I think the usability of filters in
combination with json output is worth a discussion as well.

> Those resentments were related to the patchsets complexity and size.

I didn't see any problem with that in the first place. It is indeed a
big change, achieving something like that without a big patch set is
unlikely.
