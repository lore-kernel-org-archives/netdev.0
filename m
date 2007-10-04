From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [patch 3/3] git-net: sctp build fix (not for applying)
Date: Thu, 04 Oct 2007 11:02:24 -0400
Message-ID: <47050080.8080309@hp.com>
References: <200710022104.l92L4dvJ022234@imap1.linux-foundation.org>	<47039E3F.9020305@hp.com> <20071003.164542.107940171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:54548 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281AbXJDPC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 11:02:26 -0400
In-Reply-To: <20071003.164542.107940171.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Wed, 03 Oct 2007 09:50:55 -0400
> 
>> akpm@linux-foundation.org wrote:
>>> From: Andrew Morton <akpm@linux-foundation.org>
>>>
>>> net/sctp/sm_statetable.c:551: error: 'sctp_sf_tabort_8_4_8' undeclared here (not in a function)
>>>
>> Andrew, is the a result of the merge of net-2.6.24 with net-2.6?  
> 
> Actually, it is a result of merging with Linus's tree since your SCTP
> bits were there already, that's why Andrew hit this.
> 
>> That's the only way I see this happening.
> 
> Right.
> 
> I'll resolve this cleanly as I rebase net-2.6.24 today.

OK.  Thanks David.

-vlad
