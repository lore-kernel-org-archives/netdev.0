From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH net-2.6.25 6/8] sctp: Use ipv4_is_<type>
Date: Fri, 14 Dec 2007 14:17:35 -0500
Message-ID: <4762D6CF.50109@hp.com>
References: <1197589141-7020-5-git-send-email-joe@perches.com>	<1197589141-7020-6-git-send-email-joe@perches.com>	<4762D570.7060207@hp.com> <20071214.111436.32787690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, sri@us.ibm.com,
	lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:42944 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbXLNTRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 14:17:37 -0500
In-Reply-To: <20071214.111436.32787690.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Fri, 14 Dec 2007 14:11:44 -0500
> 
>> Joe Perches wrote:
>>> Signed-off-by: Joe Perches <joe@perches.com>
>> Thanks Joe.  I've put this into my tree.
> 
> You can't, because your tree won't build without his first patch and I
> have to approve that and stick it into my tree first.
> 
> Just let me review and potentially pick up all of
> Joe's stuff since we have this dependency.
> 

Ok.  In that case, you can have my ACK for the SCTP stuff.

-vlad
