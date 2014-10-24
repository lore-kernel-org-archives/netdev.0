From: Martin Lau <kafai@fb.com>
Subject: Re: [PATCH RFC v5 net 0/3] ipv6: Reduce the number of fib6_lookup()
 calls from ip6_pol_route()
Date: Fri, 24 Oct 2014 10:28:21 -0700
Message-ID: <20141024172820.GB17146@devbig242.prn2.facebook.com>
References: <1413837765-5446-1-git-send-email-kafai@fb.com>
 <20141024.001550.1808591527768047773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:10851 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756140AbaJXR2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 13:28:24 -0400
Content-Disposition: inline
In-Reply-To: <20141024.001550.1808591527768047773.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Can you cook up some clean patches against the net_test_tools repo so
> that people can use it for both ipv4 and ipv6 route lookup measurements?
Yes, will do.

Thanks,
--Martin
