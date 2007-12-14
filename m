From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 6/8] sctp: Use ipv4_is_<type>
Date: Fri, 14 Dec 2007 11:14:36 -0800 (PST)
Message-ID: <20071214.111436.32787690.davem@davemloft.net>
References: <1197589141-7020-5-git-send-email-joe@perches.com>
	<1197589141-7020-6-git-send-email-joe@perches.com>
	<4762D570.7060207@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, sri@us.ibm.com,
	lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46641
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752071AbXLNTOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 14:14:42 -0500
In-Reply-To: <4762D570.7060207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 14 Dec 2007 14:11:44 -0500

> Joe Perches wrote:
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> Thanks Joe.  I've put this into my tree.

You can't, because your tree won't build without his first patch and I
have to approve that and stick it into my tree first.

Just let me review and potentially pick up all of
Joe's stuff since we have this dependency.
