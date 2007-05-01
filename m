From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] AFS: Fix use of __exit functions from __init path
Date: Tue, 1 May 2007 20:30:56 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0705012030450.27246@anakin>
References: <20070501181706.28008.10566.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	Linux Kernel Development <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hoboe2bl1.telenet-ops.be ([195.130.137.73]:34045 "EHLO
	hoboe2bl1.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031239AbXEASa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 14:30:59 -0400
In-Reply-To: <20070501181706.28008.10566.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 May 2007, David Howells wrote:
> Fix use of __exit functions from __init path.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
