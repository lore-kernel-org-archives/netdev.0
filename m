From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute2 PATCH] tc: fq: allow setting and retrieving flow
 refill delay
Date: Wed, 23 Sep 2015 16:04:12 -0700
Message-ID: <20150923160412.62038e8e@urahara>
References: <e318ef141f8d46e588ae32e45ca366e0@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"fw@strlen.de" <fw@strlen.de>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:19021 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755037AbbIWXEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:04:14 -0400
In-Reply-To: <e318ef141f8d46e588ae32e45ca366e0@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Sep 2015 14:25:47 +0000
Phil Sutter <phil@nwl.cc> wrote:

> Code to parse and export this tuneable via netlink is already present in
> sched_fq.c of the kernel, so not making it accessible for users would be
> a waste of resources.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied, thanks
