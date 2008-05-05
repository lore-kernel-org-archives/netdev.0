From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 12/18] flag parametersi: NONBLOCK in anon_inode_getfd
Date: Sun, 4 May 2008 21:54:28 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805042154060.8307@alien.or.mcafeemobile.com>
References: <200805050342.m453gkgJ029847@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:54279 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbYEEEy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 00:54:29 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S28A924> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Mon, 5 May 2008 00:54:28 -0400
In-Reply-To: <200805050342.m453gkgJ029847@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 May 2008, Ulrich Drepper wrote:

> Building on the previous change to anon_inode_getfd, this patch introduces
> support for handling of O_NONBLOCK in addition to the already supported
> O_CLOEXEC.  Following patches will take advantage of this support.  As
> can be seen, the additional support for supporting this functionality is
> minimal.
> 
> Signed-off-by: Ulrich Drepper <drepper@redhat.com>

Acked-by: Davide Libenzi <davidel@xmailserver.org>



- Davide


