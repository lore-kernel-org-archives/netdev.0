From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24-rc6-mm1
Date: Tue, 8 Jan 2008 16:59:48 +0100
Message-ID: <20080108155948.GC26114@elte.hu>
References: <64bb37e0801060335k4afb3134u9c6fadb57d525dc5@mail.gmail.com> <20080106223650E.tomof@acm.org> <64bb37e0801061203l503f29f0hd922a1347f8169ac@mail.gmail.com> <20080107151639P.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: just.for.lkml@googlemail.com, tomof@acm.org,
	akpm@linux-foundation.org, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, netdev@vger.kernel.org,
	tom@opengridcomputing.com
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:40633 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753120AbYAHQAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 11:00:53 -0500
Content-Disposition: inline
In-Reply-To: <20080107151639P.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> The patches are available at:
> 
> http://www.kernel.org/pub/linux/kernel/people/tomo/iommu/
> 
> Or if you prefer the git tree:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/tomo/linux-2.6-misc.git 
> iommu-sg-fixes

btw., these improvements to the IOMMU code are in -mm and will go into 
v2.6.25, right? The changes look robust to me.

	Ingo
