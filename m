From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/4]
 ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes
Date: Wed, 17 Oct 2007 19:50:51 -0700
Message-ID: <20071017195051.31af9030.akpm@linux-foundation.org>
References: <200710162124.l9GLOCTB017977@imap1.linux-foundation.org>
	<20071017.193721.48531740.davem@davemloft.net>
	<20071017194759.bc3571b3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, Emilian.Medve@Freescale.com,
	galak@gate.crashing.org, leoli@Freescale.com, paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50246 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759838AbXJRCvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:51:05 -0400
In-Reply-To: <20071017194759.bc3571b3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Oct 2007 19:47:59 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> - When I applied it I saw valid checkpatch warnings, so I queed a patch to
> fix them, called foo-checkpatch-fixes.patch with the intention that it later be
> folded into foo.patch

incidentally, the reason I do it this way is to attempt to educate
patch originators into running checkpatch, rather than out of sheer joy for
the task.  Hopefully I'll have to do this less often as time passes.

box:/usr/src/25> ls -lR patches|grep checkpatch-fixes | wc -l 
38

