From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] reintroduce accept4
Date: Fri, 14 Nov 2008 09:25:52 +1100
Message-ID: <18716.43376.534965.688695@cargo.ozlabs.ibm.com>
References: <200810261641.m9QGfotr024285@hs20-bc2-1.build.redhat.com>
	<517f3f820811131351l1305b2d2u43ab4e0601d97f93@mail.gmail.com>
	<20081113140541.23754cad.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Michael Kerrisk" <mtk.manpages@gmail.com>,
	subrata@linux.vnet.ibm.com, linux-arch@vger.kernel.org,
	drepper@redhat.com, linux-kernel@vger.kernel.org,
	torvalds@linux-foundation.org, linux-api@vger.kernel.org,
	linux-man@vger.kernel.org, davidel@xmailserver.org,
	netdev@vger.kernel.org, roland@redhat.com, oleg@tv-sign.ru,
	hch@lst.de, davem@davemloft.net, alan@redhat.com, jakub@redhat.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56014 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752722AbYKMW0C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2008 17:26:02 -0500
In-Reply-To: <20081113140541.23754cad.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton writes:

> > I think Ulrich wanted to try to see this patch in for 2.6.28; it's
> > past the merge window of course, so it's up to you, but I have no
> > problem with that.
> 
> That's easy - I'll send it to Linus and let him decide ;)

Ulrich's patch only updated x86.  If you're going to send it to Linus,
please give us other architecture maintainers a chance to get patches
to you to wire it up on our architectures, and then send Linus the
combined patch.

Paul.
