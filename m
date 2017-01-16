From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] qed: Replace memset with eth_zero_addr
Date: Mon, 16 Jan 2017 11:46:06 -0500 (EST)
Message-ID: <20170116.114606.1692928906878877115.davem@davemloft.net>
References: <1484538277-21376-1-git-send-email-mayhs11saini@gmail.com>
        <20170115.233830.123911280062970298.davem@davemloft.net>
        <20170116092435.GA2970@mystictot>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
To: mayhs11saini@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43876 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbdAPQqM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 11:46:12 -0500
In-Reply-To: <20170116092435.GA2970@mystictot>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shyam Saini <mayhs11saini@gmail.com>
Date: Mon, 16 Jan 2017 14:54:35 +0530

> On Sun, Jan 15, 2017 at 11:38:30PM -0500, David Miller wrote:
>> 
>> Please do not ever submit two patches which have the same exact commit
>> header line, as these two patches do.
>> 
>> When someone looks into the shortlog of GIT history all they will see
>> is "qed: Replace memset with eth_zero_addr" twice.
>> 
>> This gives the reader no idea what might be different between those
>> two changes.
>> 
>> Therefore you must give unique a commit header text for each change,
>> which communicates sufficiently what is different in each change.
> 
> Thanks a lot for correcting me. I'll take care of this thing.
> 
> I'm resending these two patches as 
> 	1). qed: Replace memset with eth_zero_addr
> 	2). qed: Use eth_zero_addr
> 	
> I hope it resolves same commit header line conflict.

You aren't understanding the point.

Those two lines still say exactly the same thing.

What is different about these two changes?  The answer to that question
must propagate into those lines of text.
