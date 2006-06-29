From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx: "transmit timed out" and apparent hang with "preemptible periodic work" patches
Date: Thu, 29 Jun 2006 17:07:54 +0200
Message-ID: <200606291707.55172.mb@bu3sch.de>
References: <87ac80ps5o.fsf@briny.internal.ondioline.org> <200606261727.24266.mb@bu3sch.de> <871wt8xtc9.fsf@briny.internal.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:64493
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750772AbWF2PIE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 11:08:04 -0400
To: Paul Collins <paul@briny.ondioline.org>
In-Reply-To: <871wt8xtc9.fsf@briny.internal.ondioline.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 29 June 2006 10:24, Paul Collins wrote:
> Michael Buesch <mb@bu3sch.de> writes:
> 
> > On Monday 26 June 2006 14:43, Michael Buesch wrote:
> >> Try to get more logs.
> >> I suggest to do a netconsole for logging.
> >
> > Also note that current softmac trees have a patch missing.
> > It seems it got lost somewhere after my merge request.
> > I already contacted John in private for this, but no reply, yet.
> > The patch is attached. Maybe it fixes your issue.
> 
> On a preempt kernel I can trigger the hang easily,

How? I need to reproduce it to get a clue and fix it. :)
I have no idea where it might come from (I don't even know
what exactly happens).

And please provide a _full_ dmesg log without comments inbetween
after triggering the hang (with a full Controller Restart cycle).

-- 
Greetings Michael.
