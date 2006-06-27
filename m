From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET] Towards accurate incoming interface information
Date: Tue, 27 Jun 2006 13:24:11 -0700 (PDT)
Message-ID: <20060627.132411.27951532.davem@davemloft.net>
References: <20060626145446.948105000@postel.suug.ch>
	<20060627150727.GV1376@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9900
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161277AbWF0UYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:24:12 -0400
To: tgraf@suug.ch
In-Reply-To: <20060627150727.GV1376@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 27 Jun 2006 17:07:27 +0200

> * Thomas Graf <tgraf@suug.ch> 2006-06-26 16:54
> > This patchset transforms skb->input_dev based on a device
> > reference to skb->iif based on an interface index moving
> > towards accurate iif information for routing and classification
> > through the following changesets:
> 
> Hold on with this, I haven't noticed this ifb device
> go in and thus missed to update it. I'll post an
> updated patch shortly

Ok.
