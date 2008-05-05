From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 16/18] flag parameters: NONBLOCK in timerfd_create
Date: Sun, 4 May 2008 21:40:48 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805042139570.8307@alien.or.mcafeemobile.com>
References: <200805050342.m453gkae029859@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:39644 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbYEEEku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 00:40:50 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S28A908> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Mon, 5 May 2008 00:40:48 -0400
In-Reply-To: <200805050342.m453gkae029859@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 May 2008, Ulrich Drepper wrote:

> This patch adds support for the TFD_NONBLOCK flag to timerfd_create.  The
> additional changes needed are minimal thanks to the previous preparation.
> 
> The following test must be adjusted for architectures other than x86 and
> x86-64 and in case the syscall numbers changed.

> Signed-off-by: Ulrich Drepper <drepper@redhat.com>

Acked-by: Davide Libenzi <davidel@xmailserver.org>



- Davide


