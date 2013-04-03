From: Tejun Heo <htejun@gmail.com>
Subject: Re: this cpu documentation
Date: Wed, 3 Apr 2013 14:18:15 -0700
Message-ID: <20130403211815.GC3411@htj.dyndns.org>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com>
 <1364475933.15753.36.camel@edumazet-glaptop>
 <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com>
 <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
 <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com>
 <1364833887.5113.161.camel@edumazet-glaptop>
 <0000013dd1a20ebf-4a76fb06-4b9d-492e-9d77-4b3f43aceca7-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org,
	srostedt@linux.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:47838 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757901Ab3DCVSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 17:18:20 -0400
Received: by mail-pd0-f170.google.com with SMTP id 10so1063604pdi.1
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 14:18:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <0000013dd1a20ebf-4a76fb06-4b9d-492e-9d77-4b3f43aceca7-000000@email.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 03, 2013 at 08:41:32PM +0000, Christoph Lameter wrote:
> 
> From: Christoph Lameter <cl@linux.com>
> Subject: this_cpu: Add documentation
> 
> Document the rationale and the way to use this_cpu operations.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Applied to percpu/for-3.10 with the file renamed to this_cpu_ops.txt.

Thanks.

-- 
tejun
