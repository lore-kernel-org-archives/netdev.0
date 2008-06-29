From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] net: em_cmp.c use unaligned access helpers
Date: Sun, 29 Jun 2008 11:55:38 +0200
Message-ID: <20080629095538.GN20815@postel.suug.ch>
References: <1214428440.6908.1.camel@brick> <20080627.201649.95998057.davem@davemloft.net> <20080629095424.GM20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: harvey.harrison@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33725 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752756AbYF2JzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jun 2008 05:55:17 -0400
Content-Disposition: inline
In-Reply-To: <20080629095424.GM20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Thomas Graf <tgraf@suug.ch> 2008-06-29 11:54
> I wasn't aware of these flags when I wrote the code initially.

macros I mean...
