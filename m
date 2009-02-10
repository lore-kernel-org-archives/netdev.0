From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] Re: can't add tc multiq
Date: Tue, 10 Feb 2009 00:11:33 -0800 (PST)
Message-ID: <20090210.001133.151317531.davem@davemloft.net>
References: <20090209214446.GA2542@ami.dom.local>
	<20090209144052.6636f069@extreme>
	<20090210074154.GA4190@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, slavon@bigtelecom.ru, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36744
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750735AbZBJILj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 03:11:39 -0500
In-Reply-To: <20090210074154.GA4190@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 10 Feb 2009 07:41:54 +0000

> pkt_sched: sch_multiq: Change errno on non-multiqueue devices use.
> 
> Current "RTNETLINK answers: Invalid argument" warning, while trying to
> add multiq qdisc to non-multiqueue device, isn't very helpful and some
> of these devs can be changed btw., so let's use a better errno.
> 
> With feedback from Stephen Hemminger <shemminger@vyatta.com>
> 
> Reported-by: Badalian Vyacheslav <slavon@bigtelecom.ru>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks everyone.
