From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 2/4] net_sched: gred: eliminate redundant DP prio comparisons
Date: Thu, 13 Sep 2012 14:00:30 -0400
Message-ID: <50521F3E.7010101@mojatatu.com>
References: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu> <1347549755-19438-2-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bruce Osler <brosler@cisco.com>,
	Cyril Chemparathy <cyril@ti.com>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:49044 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296Ab2IMSAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 14:00:34 -0400
Received: by vcbfo13 with SMTP id fo13so2844515vcb.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 11:00:33 -0700 (PDT)
In-Reply-To: <1347549755-19438-2-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-09-13 11:22 AM, David Ward wrote:
> Each pair of DPs only needs to be compared once when searching for
> a non-unique prio value.
>
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
