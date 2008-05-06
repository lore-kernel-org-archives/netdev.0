From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/18] flag parameters: socket and socketpair
Date: Mon, 5 May 2008 19:42:21 -0700
Message-ID: <20080505194221.4349418b.akpm@linux-foundation.org>
References: <200805050342.m453gktl029817@devserv.devel.redhat.com>
	<20080505185850.789d870a.akpm@linux-foundation.org>
	<481FC38A.6070805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60771 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751057AbYEFCnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 22:43:13 -0400
In-Reply-To: <481FC38A.6070805@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 05 May 2008 19:33:46 -0700 Ulrich Drepper <drepper@redhat.com> wrote:

> Andrew Morton wrote:
> > afaict we only ever remap one or two flags.
> 
> So far.  I have plans for at least one more flag: the one we'll
> hopefully have sometime soon to request non-sequential file descriptors.
>  There is no reason why there shouldn't be even more in future.

oh.  More overhead.

Sorry to sound slow, but what do we gain from all this?  Your covering
description was heavy in references to some earlier discussion to which I
obviously paid little attention and now I'm lost.

