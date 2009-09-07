From: David Miller <davem@davemloft.net>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Mon, 07 Sep 2009 01:50:39 -0700 (PDT)
Message-ID: <20090907.015039.154939751.davem@davemloft.net>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>
	<4AA14377.9020200@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50725
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752322AbZIGIuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 04:50:24 -0400
In-Reply-To: <4AA14377.9020200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I gave these patches a very basic bashing with NIU, and it
seems to work from what I've tried.

I know that Jarek has expressed some questions about the callback
scheme used by the new mq classful qdisc, as well as some other
issues, but we can refine this using followon patches.

For now I'm pushing this out so that it gets wider testing.

Thanks everyone!
