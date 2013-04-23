From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: separate out procfs code from mcast.c
Date: Tue, 23 Apr 2013 15:41:33 +0800
Message-ID: <1366702893.21136.28.camel@cr0>
References: <1366701302.21136.19.camel@cr0>
	 <20130423.031805.544535198246859192.davem@davemloft.net>
	 <1366702220.21136.23.camel@cr0>
	 <20130423.033620.1101068519499870853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39216 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755267Ab3DWHlr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Apr 2013 03:41:47 -0400
In-Reply-To: <20130423.033620.1101068519499870853.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 03:36 -0400, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Tue, 23 Apr 2013 15:30:20 +0800
> 
> > This is hard to do, as in the email I replied to Stephen. So I
> > prefer to just add a Kconfig dependency, at least for now.
> 
> A Kconfig hack is exactly what I've told you is an unacceptable
> solution.

Please enlighten me for a third solution. :)
