From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [dropped? patch] netdev: fix smc911 compile error
Date: Sat, 23 Dec 2006 15:33:53 -0500
Message-ID: <458D92B1.5090303@pobox.com>
References: <200612231501_MC3-1-D628-DCA5@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57008 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753712AbWLWUd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Dec 2006 15:33:56 -0500
To: Chuck Ebbert <76306.1226@compuserve.com>
In-Reply-To: <200612231501_MC3-1-D628-DCA5@compuserve.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:
> From: Vitaly Wool <vitalywool@gmail.com>
> 
> Fix compilation failure for smc911x.c when NET_POLL_CONTROLLER is set.
> 
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
> Is not upstream and doesn't seem to be in upstream-fixes either.

It's in Linus's upstream.  netdev-2.6.git#upstream is a few days behind.

	Jeff



