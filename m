From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH 0/7][IP] IProute2 ip command updates
Date: Tue, 28 Nov 2006 12:19:39 +0900
Message-ID: <456BAACB.8040508@linux-ipv6.org>
References: <200611241231.23953.nakam@linux-ipv6.org> <20061127101255.4aee9bcd@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: takamiya@po.ntts.co.jp, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:5595 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S935053AbWK1DTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 22:19:41 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061127101255.4aee9bcd@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Plan is to put out new iproute2 release after 2.6.19 final

OK.

As you know, netlink related interface is changed at 2.6.19.
I have another patches for iproute2 (libnetlink fix and Mobile
IPv6 support). Those are depends on 2.6.19 headers.

So this time I'd like to know when to update your tree's kernel headers, too.
To use this chance to test with your tree, can I send my patches with the
header update to 2.6.19-rcX in advance (updating headers by you is also fine
with me), or just wait till 2.6.19 final release is done?

Regards,

-- 
Masahide NAKAMURA
