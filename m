From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net v2 02/03] vxlan: handle skb_clone failure
Date: Mon, 10 Jun 2013 14:01:03 -0700 (PDT)
Message-ID: <20130610.140103.408200022594013557.davem@redhat.com>
References: <20130610195822.888424947@vyatta.com>
	<20130610131230.486f43fc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1763 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752158Ab3FJVBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 17:01:05 -0400
In-Reply-To: <20130610131230.486f43fc@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 10 Jun 2013 13:12:30 -0700

> skb_clone can fail if out of memory. Just skip the fanout.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
