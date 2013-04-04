From: Christoph Lameter <cl@linux.com>
Subject: Re: [PERCPU] Remove & in front of this_cpu_ptr
Date: Thu, 4 Apr 2013 14:21:57 +0000
Message-ID: <0000013dd56ce988-aff8039a-dcd8-4267-b1c8-b8db60b4e4cd-000000@email.amazonses.com>
References: <1364475933.15753.36.camel@edumazet-glaptop> <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com> <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com> <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com>
 <1364833887.5113.161.camel@edumazet-glaptop> <alpine.DEB.2.02.1304031540110.3444@gentwo.org> <0000013dd1a300fb-1fbb26a9-77a7-4c24-95ff-f088309206d9-000000@email.amazonses.com> <20130403212450.GD3411@htj.dyndns.org> <1365024575.13853.39.camel@edumazet-glaptop>
 <0000013dd5517d80-151c27ac-ebf3-4ec7-bcd4-c85a7975852e-000000@email.amazonses.com> <20130404140040.GB9425@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a9-66.smtp-out.amazonses.com ([54.240.9.66]:50626 "EHLO
	a9-66.smtp-out.amazonses.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761829Ab3DDObU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 10:31:20 -0400
In-Reply-To: <20130404140040.GB9425@htj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Apr 2013, Tejun Heo wrote:

> Right, this is true, and we *do* wanna support this_cpu ops other than
> this_cpu_ptr on per-cpu struct fields.  The usage is still somewhat
> unusual tho.  Can we please add documentation in the comments too?

I posted a patch adding documentation yesterday and you took it.
???

Add comments where?
