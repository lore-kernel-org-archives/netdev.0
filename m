From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 1/3] igmp: fix return value of some functions
Date: Mon, 10 Jun 2013 11:09:04 +0800
Message-ID: <1370833744.11543.4.camel@cr0>
References: <1370689003.868.3.camel@cr0>
	 , <1370485211-11498-1-git-send-email-amwang@redhat.com>
	 <OFF0DFA533.AF670FB8-ON85257B82.006E0B5C-85257B82.006F58EF@us.ibm.com>
	 <OF76532841.5DDD0996-ON87257B85.000C25DF-87257B85.000C25E6@us.ibm.com>
	 <1370833653.11543.3.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev-owner@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026Ab3FJDJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jun 2013 23:09:18 -0400
In-Reply-To: <1370833653.11543.3.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-10 at 11:07 +0800, Cong Wang wrote:
> 
> Are you suggesting to just make ip_mc_leave_src() void?

I meant ip_mc_del_src() of course...
