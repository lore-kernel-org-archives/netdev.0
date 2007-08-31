From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Fri, 31 Aug 2007 18:01:28 -0400
Message-ID: <46D88FB8.5000503@garzik.org>
References: <469E75AA.7040109@pimpmylinux.org> <Pine.LNX.4.64.0707181620460.13912@localhost.localdomain> <20070718134012.cde2f956.randy.dunlap@oracle.com> <469E7BE1.6090401@garzik.org> <Pine.LNX.4.64.0707181648330.15343@localhost.localdomain> <20070718210903.GM3801@stusta.de> <Pine.LNX.4.64.0707181712340.16513@localhost.localdomain> <20070719054742.GN3801@stusta.de> <Pine.LNX.4.64.0707190331330.11902@localhost.localdomain> <469F240E.9040205@s5r6.in-berlin.de> <Pine.LNX.4.64.0707190523001.19216@localhost.localdomain> <20070719083109.13b2ab56.rdunlap@xenotime.net> <Pine.LNX.4.64.0707191213130.8844@localhost.localdomain> <469FE045.3070403@simon.arlott.org.uk> <20070831102527.09fb42c0.rdunlap@xenotime.net> <Pine.LNX.4.64.0708311318220.18158@localhost.localdomain> <46D858A9.4080506@garzik.org>
 <Pine.LNX.4.64.0708311643080.27345@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	Simon Arlott <simon@fire.lp0.eu>, sam@ravnborg.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Adrian Bunk <bunk@stusta.de>,
	Gabriel C <crazy@pimpmylinux.org>, netdev@vger.kernel.org
To: "Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33037 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbXHaWBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 18:01:37 -0400
In-Reply-To: <Pine.LNX.4.64.0708311643080.27345@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert P. J. Day wrote:
> On Fri, 31 Aug 2007, Jeff Garzik wrote:
> 
>> Robert P. J. Day wrote:
> 
>>> i'm sure i'm going to get shouted down here, but i really disagree
>>> with "BROKEN" being considered a "maturity level".  IMHO, things
>>> like EXPERIMENTAL, DEPRECATED and OBSOLETE represent maturity
>>> levels, for what i think are obvious reasons.
>>>
>>> something like BROKEN, though, has *nothing* to do with maturity.
>>> a feature can be any of those maturity levels, and simultaneously
>>> be BROKEN.  i consider BROKEN to be what i call a "status", and
>>> different status levels might be the default of normal, or
>>> KIND_OF_FLAKY or TOTALLY_BORKED -- that's where BROKEN would fit
>>> in.
>> BROKEN is definitely a maturity level.
> 
> no.  it's not.  end of discussion.  you're wrong.
> 
> the concept of "maturity level" reflects where in the life cycle some
> feature is.  it will typically start as "bleeding edge" or
> "experimental" or something like that, eventually stabilize to be
> normal (which would be the obvious default), after which, when its
> value starts to run out and it begins showing its age, it becomes
> "deprecated" and eventually "obsolete"  it's a natural and obvious
> progression.
> 
> on the other hand, a feature can be "broken" at *any* point in that
> life cycle -- that's why it is absolutely *not* a maturity level.
> please don't fight with me on this, jeff.  you're simply wrong.

Get off your high horse and actually look at the patches that mark 
things BROKEN.

'deprecrated' and 'obsolete' are matters of discussed opinion, 
describing the utility of the code in question.  'broken' describes the 
state of the code itself.

Clear difference.

	Jeff, one who actually marks this stuff as such



