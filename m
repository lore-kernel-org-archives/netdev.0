From: Paul Moore <paul.moore@hp.com>
Subject: Re: speaking of stacks
Date: Fri, 4 Apr 2008 18:31:43 -0400
Message-ID: <200804041831.43578.paul.moore@hp.com>
References: <1206969356.4424.120.camel@localhost> <200804040832.33785.paul.moore@hp.com> <1207312863.4402.80.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	joern@lazybastard.org, herbert@gondor.apana.org.au,
	James Morris <jmorris@namei.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:31386 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863AbYDDWbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 18:31:48 -0400
In-Reply-To: <1207312863.4402.80.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 April 2008 8:41:03 am jamal wrote:
> On Fri, 2008-04-04 at 08:32 -0400, Paul Moore wrote:
> > Sorry, I've been stuck under a rock for about the past month.
> > Unless somebody is really anxious to do this I'll see if I can whip
> > up an RFC patch and get it out either today or early next week.
>
> No rush - it is an enhancement not a bug fix. If you need my help let
> me know.

It would still be nice to get into 2.6.26 and I figure we only have a 
few weeks before the merge window opens.  I've got a patch cobbled 
together that does what Dave suggested plus all the other "left as an 
exercise for the reader" pieces that compiles I just haven't had a 
chance to test it yet, my test machines are busy testing some other 
bits right now.  You should see from mail from me early next week, 
review and additional testing is always welcome :)

-- 
paul moore
linux @ hp
