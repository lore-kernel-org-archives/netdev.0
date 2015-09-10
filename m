From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: IFLA_INET6_[ICMP6]STATS
Date: Thu, 10 Sep 2015 13:16:30 -0400
Message-ID: <20150910171630.GP20544@oracle.com>
References: <20150909214528.GE20544@oracle.com>
 <55F1A53E.1010908@cumulusnetworks.com>
 <20150910154819.GL20544@oracle.com>
 <20150910.101303.1945782677465930122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	raghavendra.kt@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38748 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbbIJRRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 13:17:17 -0400
Content-Disposition: inline
In-Reply-To: <20150910.101303.1945782677465930122.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/10/15 10:13), David Miller wrote:
> I don't think using such a generic netlink flag works best, the
> IFLA_EXT_MASK is definitely more suitable.

Ok, though this more of a IFLA_TRUNCATE_MASK than a IFLA_EXT_MASK.
