From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/1] ipv6: corrects sended rtnetlink message
Date: Wed, 12 Sep 2007 16:53:23 +0200
Message-ID: <20070912145323.GE18480@postel.suug.ch>
References: <20070815143322.GA25640@wq.cz> <20070821.002058.102575162.davem@davemloft.net> <20070829215119.GB15856@wq.cz> <20070906104711.GV18480@postel.suug.ch> <20070906210550.GA13542@wq.cz> <20070907101137.GX18480@postel.suug.ch> <20070912145030.GA29748@wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33962 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965975AbXILOxD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 10:53:03 -0400
Content-Disposition: inline
In-Reply-To: <20070912145030.GA29748@wq.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Milan Kocian <milon@wq.cz> 2007-09-12 16:50
> However I still think that this notitfication is redundant. I tried to look
> at XORP, bird, USAGI , quagga and to see RTM_DELLINK handling. And imho
> nobody depends on RTM_DELLINK message from ipv6.

Send a patch to remove and we'll see if anyone complains.
