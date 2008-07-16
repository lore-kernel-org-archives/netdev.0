From: Dan Williams <dcbw@redhat.com>
Subject: Re: Linux Wireless Mini-Summit -- Ottawa -- July 22, 2008
Date: Wed, 16 Jul 2008 12:27:59 -0400
Message-ID: <1216225679.21973.6.camel@localhost.localdomain>
References: <20080709190915.GA8238@tuxdriver.com>
	 <247d6d340807140805gfb6523en74384f6f47469d79@mail.gmail.com>
	 <20080715174246.GA3117@tuxdriver.com>
	 <1216145731.13411.25.camel@localhost.localdomain>
	 (sfid-20080715_201731_895315_46FC8F2F)  <1216196668.3422.2.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Guy Cohen <guy@cguy.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116AbYGPQaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 12:30:00 -0400
In-Reply-To: <1216196668.3422.2.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-16 at 10:24 +0200, Johannes Berg wrote:
> > > Not sure exactly what you mean with this one.  Are you talking about
> > > the lib80211 line item?  Or enhancements to the mac80211 component
> > > to support full(er) MAC designs?
> > 
> > I hope just lib80211.  We shouldn't be extending mac80211 to fullmac or
> > quasi-fullmac parts.  But we can certainly share a lot of stuff.
> > lib80211 is where I see any additional fullmac effort going.
> 
> Just a minor point wrt. lib80211: I see little use in creating yet
> another module since hopefully soon enough fullmac chipsets will bind
> cfg80211 anyway so all of that stuff might as well be in there.

worksforme, I don't really care where that stuff goes as long as we get
it in one place :)

Dan

