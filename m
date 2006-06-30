From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 19:44:38 +0200
Message-ID: <20060630174438.GL14627@postel.suug.ch>
References: <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch> <20060630171348.GI14627@postel.suug.ch> <44A55CF8.2040509@trash.net> <1151688732.5270.101.camel@jzny2> <44A56294.7030309@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:15546 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932958AbWF3RoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 13:44:17 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44A56294.7030309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-06-30 19:42
> I think Thomas was more complaining about the values it is set to
> and the fact that only a single redirection is possible for each
> packet, no?

I have no interest in resolving this anymore, it seems to be
a "feature" to avoid tx lock deadlocks.
