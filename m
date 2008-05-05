From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 15/18] flag parameters: NONBLOCK in eventfd
Date: Sun, 4 May 2008 21:41:25 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805042140560.8307@alien.or.mcafeemobile.com>
References: <200805050342.m453gk7s029856@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:39649 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbYEEEl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 00:41:27 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S28A90A> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Mon, 5 May 2008 00:41:26 -0400
In-Reply-To: <200805050342.m453gk7s029856@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 May 2008, Ulrich Drepper wrote:

> This patch adds support for the EFD_NONBLOCK flag to eventfd2.  The
> additional changes needed are minimal thanks to the previous preparation.
> 
> The following test must be adjusted for architectures other than x86 and
> x86-64 and in case the syscall numbers changed.

> Signed-off-by: Ulrich Drepper <drepper@redhat.com>

Acked-by: Davide Libenzi <davidel@xmailserver.org>



- Davide


