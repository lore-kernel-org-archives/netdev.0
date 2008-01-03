From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Thu, 3 Jan 2008 16:37:46 +0100
Message-ID: <64bb37e0801030737r435ff2b1r6632ab98c2286f46@mail.gmail.com>
References: <64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com>
	 <20071228150746.42b3bbc0.akpm@linux-foundation.org>
	 <64bb37e0712290851r6d41768dk270e47884713a3de@mail.gmail.com>
	 <20071230013021.GA13603@gondor.apana.org.au>
	 <64bb37e0712291934o77a3d365h56c9c31ac8437469@mail.gmail.com>
	 <64bb37e0712311215x519b10e9kd51eb745b3b7290a@mail.gmail.com>
	 <20080101120406.GA27209@gondor.apana.org.au>
	 <64bb37e0801021029u1735bb9eta53906b123abf577@mail.gmail.com>
	 <20080102215154.GA13911@gondor.apana.org.au>
	 <20080102215706.GB6480@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@suse.de>,
	netdev@vger.kernel.org, "Tom Tucker" <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:22657 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbYACPhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 10:37:47 -0500
Received: by py-out-1112.google.com with SMTP id u52so10548876pyb.10
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2008 07:37:46 -0800 (PST)
In-Reply-To: <20080102215706.GB6480@fieldses.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 2, 2008 10:57 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Jan 03, 2008 at 08:51:54AM +1100, Herbert Xu wrote:
> > The two specific trees of interest would be git-nfsd and git-net.
>
> Also, if it's git-nfsd, it'd be useful to test with the current git-nfsd
> from the for-mm branch at:
>
>         git://linux-nfs.org/~bfields/linus.git for-mm
>
> and then any bisection results (even partial) from that tree would help
> immensely....

Wrong URL, its (now?) at git://git.linux-nfs.org/projects/bfields/linux.git

Using "HEAD is now at cd7e1c9... Merge commit 'server-xprt-switch^' into for-mm"
I was able to compile&install 54 packages, so this seems to be working.

Now git-fetch'ing
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git

Torsten
