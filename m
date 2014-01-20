From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v4 net-next 3/3] ipv6: add flowlabel_consistency sysctl
Date: Sun, 19 Jan 2014 17:13:00 -0800 (PST)
Message-ID: <20140119.171300.77873139724263621.davem@redhat.com>
References: <1389975305-12477-1-git-send-email-florent.fourcot@enst-bretagne.fr>
	<1389975305-12477-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518AbaATBNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jan 2014 20:13:05 -0500
In-Reply-To: <1389975305-12477-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Fri, 17 Jan 2014 17:15:05 +0100

> With the introduction of IPV6_FL_F_REFLECT, there is no guarantee of
> flow label unicity. This patch introduces a new sysctl to protect the old
> behaviour, enable by default.
> 
> Changelog of V3:
>  * rename ip6_flowlabel_consistency to flowlabel_consistency
>  * use net_info_ratelimited()
>  * checkpatch cleanups
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Applied.
