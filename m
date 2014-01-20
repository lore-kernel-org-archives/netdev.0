From: David Miller <davem@redhat.com>
Subject: Re: [PATCH V4 net-next 2/3] ipv6: add a flag to get the flow label
 used remotly
Date: Sun, 19 Jan 2014 17:12:54 -0800 (PST)
Message-ID: <20140119.171254.1778469682199311484.davem@redhat.com>
References: <1389975305-12477-1-git-send-email-florent.fourcot@enst-bretagne.fr>
	<1389975305-12477-2-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26343 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518AbaATBNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jan 2014 20:13:00 -0500
In-Reply-To: <1389975305-12477-2-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Fri, 17 Jan 2014 17:15:04 +0100

> This information is already available via IPV6_FLOWINFO
> of IPV6_2292PKTOPTIONS, and them a filtering to get the flow label
> information. But it is probably logical and easier for users to add this
> here, and to control both sent/received flow label values with the
> IPV6_FLOWLABEL_MGR option.
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Applied.
