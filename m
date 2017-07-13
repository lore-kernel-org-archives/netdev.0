From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: sctp refcount bug.
Date: Thu, 13 Jul 2017 11:38:34 -0300
Message-ID: <20170713143834.GU18138@localhost.localdomain>
References: <20170713143639.kbfqyasw4z4kjzsf@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49780 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752251AbdGMOin (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Jul 2017 10:38:43 -0400
Content-Disposition: inline
In-Reply-To: <20170713143639.kbfqyasw4z4kjzsf@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 13, 2017 at 10:36:39AM -0400, Dave Jones wrote:
> Hit this on Linus' current tree.
> 
> 
> refcount_t: underflow; use-after-free.

Any tips on how to reproduce this?

  Marcelo
