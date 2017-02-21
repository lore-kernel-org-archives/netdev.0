From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH v2] RDS: Make user visible data types consistent
 with rest of the kernel
Date: Tue, 21 Feb 2017 06:50:48 -0800
Message-ID: <94261fe4-4f9f-e86a-3649-db9fb8e187bd@oracle.com>
References: <1487629013-4972-1-git-send-email-santosh.shilimkar@oracle.com>
 <20170220.221812.707399155770011177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24753 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752859AbdBUOu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 09:50:58 -0500
In-Reply-To: <20170220.221812.707399155770011177.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/20/17 7:18 PM, David Miller wrote:
> From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Date: Mon, 20 Feb 2017 14:16:53 -0800
>
>> Use "__uX/__sX" kernel types rather than current uint*/int* for
>> entire file.
>>
>> Reviewed-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
>> ---
>> v1->v2:
>> As suggested by David Miller, cleaned up entire header to use kernel types.
>
> Dmitry Levin already submitted a patch the other day which does this,
> and it is already in net-next.
>
I see that now. Thanks Dave !!

Regards,
Santosh
