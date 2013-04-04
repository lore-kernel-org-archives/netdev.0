From: Tejun Heo <htejun@gmail.com>
Subject: Re: this cpu documentation
Date: Thu, 4 Apr 2013 11:52:06 -0700
Message-ID: <20130404185206.GY9425@htj.dyndns.org>
References: <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
 <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
 <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com>
 <1364833887.5113.161.camel@edumazet-glaptop>
 <0000013dd1a20ebf-4a76fb06-4b9d-492e-9d77-4b3f43aceca7-000000@email.amazonses.com>
 <515F679E.8020203@infradead.org>
 <0000013dd57e7ad7-d5959142-ca41-4a53-9497-7559766aafc9-000000@email.amazonses.com>
 <515DB623.4060802@infradead.org>
 <0000013dd622cebd-a7fee90b-b297-4e92-9143-87f4771718a4-000000@email.amazonses.com>
 <515DC80B.5090403@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <cl@linux.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:60150 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762967Ab3DDSwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 14:52:10 -0400
Received: by mail-pb0-f50.google.com with SMTP id jt11so1585817pbb.9
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 11:52:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <515DC80B.5090403@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 04, 2013 at 11:35:55AM -0700, Randy Dunlap wrote:
> > +should be accessing that variable and therefore there are no concurirency
> 
>                                                                 concurrency
> again.  but hopefully Tejun has already corrected that.

Yeap, the committed version is at

  https://git.kernel.org/cgit/linux/kernel/git/tj/percpu.git/tree/Documentation/this_cpu_ops.txt?h=for-3.10

Thanks.

-- 
tejun
