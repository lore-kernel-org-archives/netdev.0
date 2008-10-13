From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: pkt_sched: cls_u32: Fix locking in u32_delete()
Date: Mon, 13 Oct 2008 06:46:47 +0000
Message-ID: <20081013064647.GA4936@ff.dom.local>
References: <20081011.150545.03070833.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, m0sia@plotinka.ru,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:48101 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbYJMGrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 02:47:08 -0400
Received: by nf-out-0910.google.com with SMTP id d3so640183nfc.21
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2008 23:47:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081011.150545.03070833.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-10-2008 00:05, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 12 Oct 2008 00:04:18 +0200
> 
>> Yes, you could be missing something, but I've forgotten what, because
>> when I found this I was much younger and brighter... and alas now I've
>> a busy weekend, so let it wait until monday.

OK, I give up! You both didn't miss anything and this patch is useless.

> You euros and your "weekends". :-)

I wish you were right with this too...

Thanks again,
Jarek P.
