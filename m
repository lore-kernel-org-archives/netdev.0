From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Prism54-devel] Re: [PATCH 0/14] prism54: bring up to sync with
 prism54.org cvs rep
Date: Thu, 27 May 2004 12:05:44 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040527120544.2fbd4b35.akpm@osdl.org>
References: <20040524083003.GA3330@ruslug.rutgers.edu>
	<40B63132.4050906@pobox.com>
	<20040527182531.GA8942@scowler.net>
	<40B63639.6080705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: schizo@debian.org, mcgrof@studorgs.rutgers.edu,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	prism54-devel@prism54.org, debian-kernel@lists.debian.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265047AbUE0THi@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40B63639.6080705@pobox.com>
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>
>  Luis, you, or somebody should create a new patch series with just the 
>  critical fixes, NO WHITESPACE/FORMATTING CHANGES mixed in, and send 
>  those first.

Whitespace changes are often nice, but they should be the very first
patch[es] in the series.  You should be able to verify that the .o file was
unchanged before and after.

That way they become a no-brainer and it becomes easier to review and
understand the substantive changes.
