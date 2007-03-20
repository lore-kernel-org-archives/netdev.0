From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 16:11:51 +0100
Message-ID: <20070320151151.GM521@postel.suug.ch>
References: <45FEEE35.6090606@reflexsecurity.com> <20070319.192206.21926062.davem@davemloft.net> <1174373645.4895.15.camel@localhost> <45FFEC78.2090708@reflexsecurity.com> <45FFF455.80003@trash.net> <45FFF675.8040501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Madden <chris@reflexsecurity.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:41608 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933618AbXCTPLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 11:11:31 -0400
Content-Disposition: inline
In-Reply-To: <45FFF675.8040501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2007-03-20 15:57
> Actually its only cls_basic thats broken, in case of route and fw
> its intentional for backwards-compatibility.

Absolutely right, thanks Patrick.
