From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: kernel BUG at net/core/skbuff.c:1048!
Date: Sun, 20 Oct 2013 20:25:23 +0200
Message-ID: <20131020182523.GF27787@order.stressinduktion.org>
References: <524E8BFB.9080708@icts.kuleuven.be> <20131005100105.GA2457@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Wim Vandersmissen <Wim.Vandersmissen@icts.kuleuven.be>,
	netdev@vger.kernel.org, kernelspam@bofh.be
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46699 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258Ab3JTSZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 14:25:25 -0400
Content-Disposition: inline
In-Reply-To: <20131005100105.GA2457@macbook.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick!

On Sat, Oct 05, 2013 at 11:01:05AM +0100, Patrick McHardy wrote:
> On Fri, Oct 04, 2013 at 11:35:55AM +0200, Wim Vandersmissen wrote:
> > Hi,
> > 
> > Got the following BUG when using ipv6 netfilter/conntrack/ipv6
> > forwarding and traffic flowing.
> > 
> > No issues in 3.4.x, but triggered in 3.10.x (introduced in 3.7)
> 
> Please also send me your 3.10.x config and the ip6tables rules you're
> using.
> 
> Are you actually using IPv6 NAT? 

Maybe the same bug was hit by someone else and was reported in kernel
bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=63331

I added him in Cc.

Greetings,

  Hannes
