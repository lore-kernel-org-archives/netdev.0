From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 19:33:31 +0200
Message-ID: <44A5606B.5080003@trash.net>
References: <20060629085111.GY1376@postel.suug.ch>	 <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch>	 <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch>	 <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch>	 <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch>	 <1151678118.5270.45.camel@jzny2>  <20060630163229.GH14627@postel.suug.ch> <1151687977.5270.91.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61058 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932798AbWF3Rdd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 13:33:33 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151687977.5270.91.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> You are attempting to change architecture (which works just fine) in the way you 
> think it should work - and then point to something as a bug because it 
> doesnt work the way you think it should work. 
> This is a problem not just with you BTW, but with Patrick as well (although he has 
> gotten better lately). There is a huge difference for example when dealing with 
> Herbert. My approach in situations like this, which you dont have to follow, is 
> to ask first what the intent was then if i dont like the intent try to convince the
> owner that there maybe better ways. Or why they are wrong. 

Well, I thought I stay out of this, but since you mention me ..

I also had the feeling it has gotten easier working with you lately,
but I can understand Thomas's pain, I had the same thoughts more than
once. Your code often does have an enormous amount of bugs and
whitespace and other stylistic problems and working with you can be
challenging for multiple reasons, for example having to go to endless,
often entirely pointless discussions for obvious fixes, especially if
you're already pissed by noticing 50 bugs at once. The reason why you
might be able to work better with Herbert is IMO that he usually
doesn't touch what you seem to feel is "your area". Besides that, I
never changed anything in your architecture, only fixed massive
amounts of bugs.

