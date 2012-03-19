From: Greg KH <greg@kroah.com>
Subject: Re: 3.0.23 WARNING: at net/ipv4/tcp_input.c:3375
 tcp_ack+0x1d62/0x2030()
Date: Mon, 19 Mar 2012 09:15:34 -0700
Message-ID: <20120319161534.GC24487@kroah.com>
References: <4F66EA0B.1080705@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:45639 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161807Ab2CSQPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 12:15:37 -0400
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 8E105214BC
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2012 12:15:36 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <4F66EA0B.1080705@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 19, 2012 at 09:10:51AM +0100, Stefan Priebe - Profihost AG wrote:
> Hi list,
> 
> today i've seen the following error / backtrace several times on a
> machine running vanilla stable 3.0.23.

Can you try 3.0.24?

thanks,

greg k-h
