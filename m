From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Mon, 3 Jul 2006 13:41:42 +0200
Message-ID: <20060703114142.GV14627@postel.suug.ch>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain> <44A8E211.4090005@trash.net> <44A8E57E.4080805@trash.net> <20060703113447.GU14627@postel.suug.ch> <44A90149.6090304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	greearb@candelatech.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:15258 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751125AbWGCLlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 07:41:21 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44A90149.6090304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-07-03 13:36
> They will as long as this feature isn't used, the RTA_TABLE
> attribute is only added to the message when the table id
> is > 255. Worked fine during my tests, or are you refering
> to something else?

Perfect, I said nothing :)
