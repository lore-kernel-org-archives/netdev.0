From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: d80211 merge plans
Date: Wed, 9 Aug 2006 13:47:44 -0700
Message-ID: <20060809204744.GN26616@instant802.com>
References: <200608090703.45651.mb@bu3sch.de> <44D9754B.3060909@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-44.dex002.intermedia.net ([64.78.21.135]:15457 "EHLO
	dhost002-44.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751360AbWHIUtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 16:49:01 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <44D9754B.3060909@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 01:40:27AM -0400, Jeff Garzik wrote:
> Michael Buesch wrote:
> >To heavily reduce maintainance burden I would like to see d80211
> >going mainline as soon as possible

> Does it have active maintainers?
> 
> The DeviceScape people seem to have disappeared for months, except for a 
> rare appearance recently by Jouni.

Unfortunately, I have been tied up in another project that required way
too much of my time last couple of months. Getting this code into
suitable state for merging it into mainline and then making sure it
remains in working condition is my highest priority and we have
freed up more of my time for this.

We are planning on using this tree in our future products and want to be
able to remain as close to the version that is in the mainline tree as
possible, so it is indeed in our interest to make sure that this gets
maintained. We have a group of people working on this and merging rest
of our AP product to be based on this version. I'll try to be more
actively involved in getting the changes submitted to wireless-dev (and
hopefully, into mainline once the code gets there).

-- 
Jouni Malinen                                            PGP id EFC895FA
