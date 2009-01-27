From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Tue, 27 Jan 2009 14:13:17 +0100
Message-ID: <20090127131317.GF23121@elte.hu>
References: <20090115183942.GA6325@elte.hu> <200901201328.24605.rusty@rustcorp.com.au> <49756E6E.2060409@kernel.org> <200901271213.18605.rusty@rustcorp.com.au> <497E705B.5000302@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	ebiederm@xmission.com, cl@linux-foundation.org, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:38470 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753248AbZA0NNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 08:13:50 -0500
Content-Disposition: inline
In-Reply-To: <497E705B.5000302@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Tejun Heo <tj@kernel.org> wrote:

> > Tejun, any chance of you updating the tj-percpu tree? My current 
> > patches are against Linus's tree, and rebasing them on yours involves 
> > some icky merging.
> 
> If Ingo is okay with it, I'm fine with it too.  Unless Ingo objects, 
> I'll do it tomorrow-ish (still big holiday here).

Sure - but please do it as a clean rebase ontop of latest, not as a 
conflict-merge, as i'd expect there to be quite many clashes.

	Ingo
