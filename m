From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5] sh_eth: ensure pm_runtime cannot suspend the device
 during init
Date: Sat, 29 Mar 2014 00:10:20 +0300
Message-ID: <5335E53C.6020208@cogentembedded.com>
References: <1395400154-25710-1-git-send-email-ben.dooks@codethink.co.uk>	<20140328.142606.2032782733436495474.davem@davemloft.net>	<5335CCBF.8030606@codethink.co.uk> <20140328.160024.136488246522581222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, laurent.pinchart+renesas@ideasonboard.com
To: David Miller <davem@davemloft.net>, ben.dooks@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:59432 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbaC1UKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:10:16 -0400
Received: by mail-la0-f50.google.com with SMTP id y1so4069356lam.37
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 13:10:15 -0700 (PDT)
In-Reply-To: <20140328.160024.136488246522581222.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/28/2014 11:00 PM, David Miller wrote:

>> I thought it was against the net next tree, given the number of
>> patches that are currently being applied to the sh_eth driver.

> Fair enough, applied to net-next, thanks!

    It probably makes sense to queue this for the stable kernels as well.

WBR, Sergei
