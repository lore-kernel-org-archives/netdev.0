From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Regression: ping -R crashes over Ipsec
Date: Mon, 23 Jul 2012 14:48:18 -0700
Message-ID: <20120723144818.4241707b@nehalam.linuxnetplumber.net>
References: <20120723143038.4ad5ac7a@nehalam.linuxnetplumber.net>
	<20120723.143728.595164943890165527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: james.davidson@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44710 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789Ab2GWVsn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 17:48:43 -0400
In-Reply-To: <20120723.143728.595164943890165527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Jul 2012 14:37:28 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> Stephen please work on a fix if you can, I'm already overloaded
> with the issues Julian has reported, thanks.

James is working on one, just wanted wider audience. For now may
have to just silently drop the ping request.
