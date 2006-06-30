From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 22:30:34 +0200
Message-ID: <20060630203034.GN14627@postel.suug.ch>
References: <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch> <1151687977.5270.91.camel@jzny2> <44A5606B.5080003@trash.net> <1151697554.5270.241.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53693 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751154AbWF3UaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 16:30:15 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151697554.5270.241.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-30 15:59
> One thing is clear in my mind at least (and i have said it several
> times): I am not as good at the semantics as either yourself or Thomas
> or Dave or Acme etc but i have tons of other things that compensate for.
> Probably "not as good" is not the best  description  - rather my brain
> cells put less respect on the stylistic commas than they do on the
> message. Perhaps it's dylexsia or me trying to subconsciouly maximize my
> time. If you push me hard, however, i will get close to do just as a
> good job as you;->  Still, cant live without you guys! 

Lack of stylistic commas is less of a concern, rather the lack of
comments and notes where absolutely essential. You explained to me
that stacking ifb devices is not supported in order to avoid tx lock
deadlocks. There is not a single note or hint anywhere that would
remotely imply this. When questioned about things like that you often
refer to notes you have somewhere on paper, promising to get back once
looked up, eventually that happens, in this thread it didn't.
