From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bonding-devel] [PATCH] bonding: cancel_delayed_work() ->
 cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 22:16:20 +0100
Message-ID: <20091217211620.GC2578@ami.dom.local>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com>
 <20091217074930.GA6779@ff.dom.local>
 <20091217133644.GD8654@ff.dom.local>
 <1261060259.10356.112.camel@johannes.local>
 <11218.1261066373@death.nxdomain.ibm.com>
 <20091217184017.GA2578@ami.dom.local>
 <97949e3e0912171049x607ded5cgf3b696a5d89129ba@mail.gmail.com>
 <29926.1261078662@death.nxdomain.ibm.com>
 <20091217205617.GB2578@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Laurent Chavey <chavey@google.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Mikhail Markine <markine@google.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Petri Gynther <pgynther@google.com>,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:57602 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765354AbZLQVQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 16:16:29 -0500
Received: by fxm21 with SMTP id 21so2307355fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 13:16:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091217205617.GB2578@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 09:56:17PM +0100, Jarek Poplawski wrote:
> loops are tricky (they omit lockdep, plus can hide some hidden
...hideousness... ;-)

Jarek P.
