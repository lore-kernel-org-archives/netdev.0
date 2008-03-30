From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH 2.6] [IPV6] MCAST: Ensure to check multicast listener(s).
Date: Sun, 30 Mar 2008 06:49:58 -0700
Message-ID: <OFA7B9706D.1E52ED5D-ON8825741C.004BE625-8825741C.004BFD53@us.ibm.com>
References: <20080330.175835.81268650.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, yoshfuji@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:52763 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbYC3NuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2008 09:50:01 -0400
In-Reply-To: <20080330.175835.81268650.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > After commit ae7bf20a6316272acfcaef5d265b18aaa54b41e4, all packets
> for multicast destinations are delivered to upper layer if
> IFF_PROMISC or IFF_ALLMULTI is set.

        Isn't that the intent of IFF_PROMISC and IFF_ALLMULTI?

                                                        +-DLS

