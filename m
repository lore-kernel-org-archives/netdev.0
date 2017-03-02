From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4 0/2] net: ethernet: bgmac: bug fixes
Date: Thu, 02 Mar 2017 12:50:15 -0800 (PST)
Message-ID: <20170302.125015.275943458708603387.davem@davemloft.net>
References: <1488307311-11933-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jon.mason@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750972AbdCBVBq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 16:01:46 -0500
In-Reply-To: <1488307311-11933-1-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@broadcom.com>
Date: Tue, 28 Feb 2017 13:41:49 -0500

> Changes in v4:
> * Added the udelays from the previous code (per David Miller)
> 
> Changes in v3:
> * Reworked the init sequence patch to only remove the device reset if
>   the device is actually in reset.  Given that this code doesn't bear
>   much resemblance to the original code, I'm changing the author of the
>   patch.  This was tested on NS2 SVK.
> 
> Changes in v2:
> * Reworked the first match to make it more obvious what portions of the
>   register were being preserved (Per Rafal Mileki)
> * Style change to reorder the function variables in patch 2 (per Sergei
>   Shtylyov)
> 
> Bug fixes for bgmac driver

Series applied.
