From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHSET] Towards accurate incoming interface information
Date: Tue, 27 Jun 2006 17:07:27 +0200
Message-ID: <20060627150727.GV1376@postel.suug.ch>
References: <20060626145446.948105000@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:13002 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1161081AbWF0PHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 11:07:06 -0400
To: davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20060626145446.948105000@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Thomas Graf <tgraf@suug.ch> 2006-06-26 16:54
> This patchset transforms skb->input_dev based on a device
> reference to skb->iif based on an interface index moving
> towards accurate iif information for routing and classification
> through the following changesets:

Hold on with this, I haven't noticed this ifb device
go in and thus missed to update it. I'll post an
updated patch shortly
