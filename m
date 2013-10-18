From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: Any suggestions for a 40G Ethernet NIC?
Date: Fri, 18 Oct 2013 09:02:46 +0800
Message-ID: <526088B6.7070503@huawei.com>
References: <5260248B.3090400@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:52367 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab3JRBC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 21:02:57 -0400
In-Reply-To: <5260248B.3090400@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/10/18 1:55, Ben Greear wrote:
> I'd like to start playing around with 40G, but doesn't seem to be too
> many such NICs available.  Does anyone have any suggestions for 40G NICs
> that work well with Linux?
> 
> Thanks,
> Ben
> 

I have the situation for test 40G for Linux, which consist of 4 82599 NICs,
and I use bonding LACP mode to test the performance, when turn on the iommu for
kernel, the performance is up to 30G, when close it, the performance is up to 38G,
what do you think about it?

Thanks.
Ding
