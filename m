From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] netpoll: call ->ndo_select_queue() in tx path
Date: Sun, 07 Oct 2012 22:34:25 +0800
Message-ID: <1349620465.2663.5.camel@cr0>
References: <1347948991-20860-1-git-send-email-amwang@redhat.com>
	 <20120919.172108.1539457128236567338.davem@davemloft.net>
	 <CAF6-1L5Gp9kpV+Koru6uAmYxQg_WQav9RVD4MVBDa2UGSoPOCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	edumazet@google.com
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753129Ab2JGOeh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2012 10:34:37 -0400
In-Reply-To: <CAF6-1L5Gp9kpV+Koru6uAmYxQg_WQav9RVD4MVBDa2UGSoPOCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-03 at 11:33 +0200, Sylvain Munaut wrote:
> Hi,
> 

Hi, Sylvain

> 
> Huh, I don't see it in the final 3.6 ?
> That's rather inconvenient :(
> 

We can backport it to 3.6 stable if you request. :)

Thanks.
