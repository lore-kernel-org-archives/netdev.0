From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5] net: sh_eth: Add support of device tree probe
Date: Tue, 19 Mar 2013 17:02:39 +0400
Message-ID: <514861EF.7050407@cogentembedded.com>
References: <1362433940-20533-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <20130305004338.GA10651@verge.net.au> <20130319042229.GG21444@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	netdev@vger.kernel.org, grant.likely@secretlab.ca,
	kuninori.morimoto.gx@renesas.com,
	devicetree-discuss@lists.ozlabs.org, magnus.damm@gmail.com,
	kda@linux-powerpc.org, Mark Rutland <mark.rutland@arm.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:62095 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648Ab3CSNDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 09:03:35 -0400
Received: by mail-la0-f52.google.com with SMTP id fs12so842762lab.11
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 06:03:33 -0700 (PDT)
In-Reply-To: <20130319042229.GG21444@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 19-03-2013 8:22, Simon Horman wrote:

>> [ Cc: Mark Rutland ]

>> On Tue, Mar 05, 2013 at 06:52:20AM +0900, Nobuhiro Iwamatsu wrote:
>>> This adds support of device tree probe for Renesas sh-ether driver.

>>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

>> Hi Iwamatsu-san,

>> could you please address the review by
>> Mark Rutland of the bindings in this patch.
>> The review was made for v2 but I believe it
>> is still applicable to v5.

>> http://www.spinics.net/lists/netdev/msg226454.html

> Ping.

    I don't think converting this driver to device tree can be achieved 
without unravelling the #ifdef mess first (which I'm currently doing).
Or at least the driver will look even uglier than today. So I see little use 
in pinging Iwamatsu-san.

WBR, Sergei
