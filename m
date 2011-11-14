From: Greg KH <greg@kroah.com>
Subject: Re: [patch 0/8 2.6.32] CVE-2010-4251: packet backlog can get too
 large
Date: Mon, 14 Nov 2011 10:11:50 -0800
Message-ID: <20111114181150.GA17614@kroah.com>
References: <20111113201336.GA1362@elgon.mountain>
 <20111113.155851.2167389434844487922.davem@davemloft.net>
 <1321226949.3059.13.camel@deadeye>
 <20111113.222410.315752972470589717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ben@decadent.org.uk, dan.carpenter@oracle.com,
	stable@vger.kernel.org, netdev@vger.kernel.org, yi.zhu@intel.com,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:42802 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755767Ab1KNSOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 13:14:11 -0500
Received: from compute2.internal (compute2.nyi.mail.srv.osa [10.202.2.42])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 37D8120AB8
	for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 13:14:11 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <20111113.222410.315752972470589717.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 13, 2011 at 10:24:10PM -0500, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sun, 13 Nov 2011 23:29:09 +0000
> 
> > But you've previously said that you are not submitting networking
> > patches to the longterm series.  Did you change your mind?
> 
> No, I in fact haven't.
> 
> But I will say that if distributions want to apply this thing, that's
> fine, but it doesn't automatically make it a good idea for -stable
> to take it too.

Thanks for letting me know, I'll drop these from my to-apply mbox.

greg k-h
