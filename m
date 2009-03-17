From: Brian Haley <brian.haley@hp.com>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 15:21:52 -0400
Message-ID: <49BFF850.7060906@hp.com>
References: <20090316233934.GD32111@codeblau.de> <49BF0A5A.2040501@hp.com> <20090317125845.GB9754@codeblau.de> <49BFC8E6.8000404@hp.com> <20090317180840.GC13270@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Felix von Leitner <felix-kernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:31003 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604AbZCQTV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 15:21:56 -0400
In-Reply-To: <20090317180840.GC13270@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Top-posting so others can see your off-list rant in full.  I see no reason to
help you any further, even though I did have a patch that would change this
behavior for you.  Good luck with your "biggest noncommercial Internet messaging
infrastructure" in the world.

-Brian

Felix von Leitner wrote:
>> Please show me a porting guide that even mentions supporting IPv4-only mode
>> through an IPv6 socket by using this method.  There is none that I know of.
> 
> Are you kidding me?
> A _porting guide_?!?
> 
> If you are trying to troll me, you just succeeded.
> 
> Now please make room so the adults can talk about the issue at hand
> while you are putting up straw men.
> 
>>> Did I mention *BSD and OSX allow this?
>> That was their decision, and it doesn't mean it's the right thing to do.
> 
> Riiiight.
> 
> There is an old joke.  The Joneses are driving on the freeway, when the
> radio sounds a warning.  "Warning!  There is a car driving the wrong way
> on the freeway!"  Says grandpa (who is driving the car) "what do you
> mean, one guy?  Hundreds!!"
> 
> Sometimes, if there are two ways to read something, and your users tell
> you which way they want it, and the competition does it the way the
> users want, and you don't, sometimes, in that case, YOU ARE WRONG.
> 
> It's that easy.
> 
> Hey, you have an hp.com email address.  Why don't you check out how
> HP-UX handles this.
> 
>> Compare your bittorrent server to Apache, which is probably the most widely-used
>> server application in the world.  It doesn't do what you're trying to do.  See
>> http://httpd.apache.org/docs/2.2/bind.html and/or browse the source code.
> 
> What is this supposed to be?  Name dropping?
> 
> I'm not impressed.
> 
> And Apache never won any speed or scalability records.  Just because
> many people use Apache does not mean it's a good piece of software.  You
> know, many more people use Windows than Linux.  That does not make
> Windows the standard to follow.  Hey, many people use sendmail!  And
> BIND!
> 
> Felix
> 
