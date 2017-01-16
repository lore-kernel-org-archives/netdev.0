From: Shyam Saini <mayhs11saini@gmail.com>
Subject: Re: [PATCH 1/2] qed: Replace memset with eth_zero_addr
Date: Mon, 16 Jan 2017 14:54:35 +0530
Message-ID: <20170116092435.GA2970@mystictot>
References: <1484538277-21376-1-git-send-email-mayhs11saini@gmail.com>
 <20170115.233830.123911280062970298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36007 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdAPJZI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 04:25:08 -0500
Received: by mail-pf0-f193.google.com with SMTP id 19so3060051pfo.3
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 01:25:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170115.233830.123911280062970298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 15, 2017 at 11:38:30PM -0500, David Miller wrote:
> 
> Please do not ever submit two patches which have the same exact commit
> header line, as these two patches do.
> 
> When someone looks into the shortlog of GIT history all they will see
> is "qed: Replace memset with eth_zero_addr" twice.
> 
> This gives the reader no idea what might be different between those
> two changes.
> 
> Therefore you must give unique a commit header text for each change,
> which communicates sufficiently what is different in each change.

Thanks a lot for correcting me. I'll take care of this thing.

I'm resending these two patches as 
	1). qed: Replace memset with eth_zero_addr
	2). qed: Use eth_zero_addr
	
I hope it resolves same commit header line conflict.

Regards,
Shyam
