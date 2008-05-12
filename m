From: "Changli Gao" <xiaosuo@gmail.com>
Subject: Re: TCP receive splice performance
Date: Mon, 12 May 2008 21:01:16 +0800
Message-ID: <412e6f7f0805120601h1121deaewd69ecebc744f258d@mail.gmail.com>
References: <200805121545.50390.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jens Axboe" <jens.axboe@oracle.com>
To: "Octavian Purdila" <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:14620 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758129AbYELNBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 09:01:22 -0400
Received: by ti-out-0910.google.com with SMTP id b6so776459tic.23
        for <netdev@vger.kernel.org>; Mon, 12 May 2008 06:01:16 -0700 (PDT)
In-Reply-To: <200805121545.50390.opurdila@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2008 at 8:45 PM, Octavian Purdila <opurdila@ixiacom.com> wrote:
>
> In the second test case the same test was performed, only this time with some
> modification in the network stack to disable the copying from/to userspace.
> Throughput was 122-123MB which is practically line-rate.
It is interesting. Could you show us your modification?

-- 
Regards，
Changli Gao(xiaosuo@gmail.com)
