From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH for kernel 3.4.x 1/1] net: neighbour: Add mcast_resolicit
 to configure the number of multicast resolicitations in PROBE state
Date: Wed, 25 Mar 2015 10:22:58 +0800
Message-ID: <55121C02.7020600@windriver.com>
References: <1427190355-1216-1-git-send-email-Yanjun.Zhu@windriver.com>	<1427190355-1216-2-git-send-email-Yanjun.Zhu@windriver.com>	<E66F6C44A7A6EA49ABFC80EA526506DF6A474235@ALA-MBA.corp.ad.wrs.com> <20150324.115551.2097254629095935718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<ulf.samuelsson@ericsson.com>,
	<hideaki.yoshifuji@miraclelinux.com>, <yoshfuji@linux-ipv6.org>,
	<Alexandre.Dietsch@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37241 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbbCYCXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 22:23:01 -0400
In-Reply-To: <20150324.115551.2097254629095935718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2015 11:55 PM, David Miller wrote:
> From: "Zhu, Yanjun" <Yanjun.Zhu@windriver.com>
> Date: Tue, 24 Mar 2015 09:51:56 +0000
>
>> This patch is needed in linux kernel 3.4.106. I made a new patch
>> based on linux kernel 3.4.106. Please let me know your advice.
> It's a new feature therefore not appropriate for -stable.
>
> It's only "needed" from your perspective, therefore you can apply it
> to your own local sources as needed.
>
>
OK. Thanks for your comments.

Zhu Yanjun
