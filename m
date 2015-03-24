From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2] ip route: support RFC4191 router preference
Date: Tue, 24 Mar 2015 15:38:23 -0700
Message-ID: <20150324153823.73625f3f@urahara>
References: <87d66392c0bc4bb087c63497a123b440@BRMWP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:61926 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752401AbbCXWic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:38:32 -0400
In-Reply-To: <87d66392c0bc4bb087c63497a123b440@BRMWP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Mar 2015 15:01:47 +0000
Lubomir Rintel <lkundrak@v3.sk> wrote:

> This allows querying and setting the route preference. It's usually set from
> the IPv6 Neighbor Discovery Router Advertisement messages.
> 
> Introduced in "ipv6: expose RFC4191 route preference via rtnetlink", enqueued
> for Linux 4.1.
> 
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>

Applied to net-next branch
