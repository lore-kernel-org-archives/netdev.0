From: Dan Williams <dcbw@redhat.com>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 25 Apr 2006 08:03:50 -0400
Message-ID: <1145966630.2297.0.camel@localhost.localdomain>
References: <20060424194006.GB21761@tuxdriver.com>
	 <20060424204044.GC21761@tuxdriver.com>
	 <1145925182.9369.1.camel@localhost.localdomain>
	 <1145964620.4571.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, jeff@garzik.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:19684 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750721AbWDYMFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 08:05:38 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1145964620.4571.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-04-25 at 13:30 +0200, Johannes Berg wrote:
> On Mon, 2006-04-24 at 20:33 -0400, Dan Williams wrote:
> 
> > Any way to get the event handling cleanup patch into 2.6.17?  It's
> > pretty much a bugfix and bcm43xx is useless with wpa_supplicant and NM
> > without the patch...
> 
> No, that's not true, the cleanup patch is exactly that, code cleanup :)
> 
> Externally, softmac behaves the same without it since your patch and
> some other patches I did on top of that have already gone in.

Ah, sorry, mistook this patch for the one that actually sent the events.

Dan


