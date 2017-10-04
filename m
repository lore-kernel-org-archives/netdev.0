From: Vignesh R <vigneshr@ti.com>
Subject: Re: [v2] cdc-ether: divorce initialisation with a filter reset and a
 generic method
Date: Wed, 4 Oct 2017 10:32:42 +0530
Message-ID: <45d5058f-9108-8be6-bc2d-98f368bc0f66@ti.com>
References: <20170522125030.21266-1-oneukum@suse.com>
 <fbe82c0f-c3d5-4dd6-62a7-b8fd2ea83302@ti.com>
 <20171003.095955.1603961040065728073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "oneukum@suse.com" <oneukum@suse.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "bjorn@mork.no" <bjorn@mork.no>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:53967 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdJDFEL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 01:04:11 -0400
In-Reply-To: <20171003.095955.1603961040065728073.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tuesday 03 October 2017 10:29 PM, David Miller wrote:
> From: Vignesh R <vigneshr@ti.com>
> Date: Tue, 3 Oct 2017 13:39:18 +0530
> 
>> Hi Dave,
>>
>> On Monday 22 May 2017 06:20 PM, Oliver Neukum wrote:
>>> Some devices need their multicast filter reset but others are crashed by that.
>>> So the methods need to be separated.
>>>
>>> Signed-off-by: Oliver Neukum <oneukum@suse.com>
>>> Reported-by: "Ridgway, Keith" <kridgway@harris.com>
>>> ---
>>
>> I see this patch was merged and said to be queued for -stable, but I
>> don't see this fix in any of the stable kernels. Would you please ask
>> for this patch to be backported to -stable kernels?
> 
> I submit networking -stable patches at a time of my own choosing.
> Usually 1 to 2 weeks after it gets applied to my tree.
> 

Sorry, but this patch was merged in v4.12-rc3(end of May) and I did not
see them in netdev stable patchwork nor in Greg's queue. Hence, I
thought this patch might have slipped through the cracks.

> Please be patient.
> 

-- 
Regards
Vignesh
