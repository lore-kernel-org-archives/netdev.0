From: Greg KH <greg@kroah.com>
Subject: Re: 3.0.23 WARNING: at net/ipv4/tcp_input.c:3375
 tcp_ack+0x1d62/0x2030()
Date: Mon, 19 Mar 2012 09:16:04 -0700
Message-ID: <20120319161604.GA2972@kroah.com>
References: <4F66EA0B.1080705@profihost.ag>
 <20120319161534.GC24487@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:41817 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161845Ab2CSQQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 12:16:06 -0400
Received: from compute1.internal (compute1.nyi.mail.srv.osa [10.202.2.41])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 21EEA21124
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2012 12:16:06 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <20120319161534.GC24487@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 19, 2012 at 09:15:34AM -0700, Greg KH wrote:
> On Mon, Mar 19, 2012 at 09:10:51AM +0100, Stefan Priebe - Profihost AG wrote:
> > Hi list,
> > 
> > today i've seen the following error / backtrace several times on a
> > machine running vanilla stable 3.0.23.
> 
> Can you try 3.0.24?

That would be 3.0.25, sorry about that.

greg k-h
