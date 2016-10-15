From: tndave <tushar.n.dave@oracle.com>
Subject: Re: [PATCH 0/2] net: Fix compiler warnings
Date: Sat, 15 Oct 2016 16:26:15 -0700
Message-ID: <aa8baef0-9b47-d2a4-531b-d9cc71bdd766@oracle.com>
References: <1476489966-9128-1-git-send-email-tushar.n.dave@oracle.com>
 <20161015.174850.1523283727470633263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chris.hyser@oracle.com,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20389 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752203AbcJOX05 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 19:26:57 -0400
In-Reply-To: <20161015.174850.1523283727470633263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/15/2016 02:48 PM, David Miller wrote:
> From: Tushar Dave <tushar.n.dave@oracle.com>
> Date: Fri, 14 Oct 2016 17:06:04 -0700
>
>> Recently, ATU (iommu) changes are submitted to linux-sparc that
>> enables 64bit DMA on SPARC. However, this change also makes
>> 'incompatible pointer type' compiler warnings inevitable on sunqe
>> and sunbmac driver.
>>
>> The two patches in series fix compiler warnings.
>
> Only the sparc tree has this build problem, so these patches
> really ought to be submitted for and applied there.
Okay. I will send these to sparclinux then.

Thanks.

-Tushar
>
> Thanks.
>
