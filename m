From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 23:10:43 +0200
Message-ID: <20060630211043.GO14627@postel.suug.ch>
References: <44A5606B.5080003@trash.net> <1151697554.5270.241.camel@jzny2> <20060630203034.GN14627@postel.suug.ch> <20060630.133348.68039806.davem@davemloft.net> <1151700884.5270.278.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43966 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932559AbWF3VKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 17:10:22 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151700884.5270.278.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-30 16:54
> I agree - and i try hard to document but at times there's too much
> and a line needs to be drawn.
> As an example:
> the eth->ifb->ifb case though is a very corner case. All the IMQ types
> need to only redirect to one ifb; while i test it ive always seen the
> test as more of a boundary check than a useful setup.

Maybe you should just start by explaining why it doesn't work,
your original explanation doesn't make much sense.

> And Thomas: I do keep notebooks ;-> I doodle about everything, they dont
> all fit in my knapsack anymore so sometimes when i say i will go and
> refer to my notes, it is real.

It's plain arrogant to rely code understanding on information that
is not available to others. It makes everyone being dependant on
you, very nice.

To put it in another way, if you would do your job right when
writing the code, contacting or CCing you upon changes would
be only of a formal matter since the code is understandable and
the intent is clear or documented.
