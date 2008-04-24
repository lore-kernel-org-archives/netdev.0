From: "Michael Kerrisk" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] alternative to sys_indirect, part 1
Date: Thu, 24 Apr 2008 14:27:28 +0200
Message-ID: <517f3f820804240527l66e4372dt9d6cdc293e35899d@mail.gmail.com>
References: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org
To: "Ulrich Drepper" <drepper@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758021AbYDXM1p@vger.kernel.org>
In-Reply-To: <200804240403.m3O43us8028699@devserv.devel.redhat.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/24/08, Ulrich Drepper <drepper@redhat.com> wrote:
> The alternative to using sys_indirect is to create a whole bunch of new
>  syscalls.  Here the beginning.  These are the socket interfaces which
>  create file descriptors and therefore need a flags parameter to let
>  the caller decide about setting the close-on-exit bit.

Ulrich,

Could you please CC me on patches that make kernel-userland API changes.

Cheers,

Michael
