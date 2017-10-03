From: David Miller <davem@davemloft.net>
Subject: Re: [v2] cdc-ether: divorce initialisation with a filter reset and
 a generic method
Date: Tue, 03 Oct 2017 09:59:55 -0700 (PDT)
Message-ID: <20171003.095955.1603961040065728073.davem@davemloft.net>
References: <20170522125030.21266-1-oneukum@suse.com>
        <fbe82c0f-c3d5-4dd6-62a7-b8fd2ea83302@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oneukum@suse.com, netdev@vger.kernel.org, bjorn@mork.no
To: vigneshr@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46800 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751761AbdJCQ74 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 12:59:56 -0400
In-Reply-To: <fbe82c0f-c3d5-4dd6-62a7-b8fd2ea83302@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vignesh R <vigneshr@ti.com>
Date: Tue, 3 Oct 2017 13:39:18 +0530

> Hi Dave,
> 
> On Monday 22 May 2017 06:20 PM, Oliver Neukum wrote:
>> Some devices need their multicast filter reset but others are crashed by that.
>> So the methods need to be separated.
>> 
>> Signed-off-by: Oliver Neukum <oneukum@suse.com>
>> Reported-by: "Ridgway, Keith" <kridgway@harris.com>
>> ---
> 
> I see this patch was merged and said to be queued for -stable, but I
> don't see this fix in any of the stable kernels. Would you please ask
> for this patch to be backported to -stable kernels?

I submit networking -stable patches at a time of my own choosing.
Usually 1 to 2 weeks after it gets applied to my tree.

Please be patient.
