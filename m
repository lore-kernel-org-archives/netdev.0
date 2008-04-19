From: corbet@lwn.net (Jonathan Corbet)
Subject: Re: [PATCH 2/5] /dev/vring: simple userspace-kernel ringbuffer interface.
Date: Sat, 19 Apr 2008 09:02:04 -0600
Message-ID: <8793.1208617324@vena.lwn.net>
References: <20080418115959.6b8fdfa7.akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761788AbYDSPCV@vger.kernel.org>
In-reply-to: Your message of "Fri, 18 Apr 2008 11:59:59 PDT."
             <20080418115959.6b8fdfa7.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So I think it would be good to plonk the proposed interface on the table
> and have a poke at it.  Is it compat-safe?  Is it extensible in a
> backward-compatible fashion?  Are there future-safe changes we should make
> to it?  Can Michael Kerrisk understand, review and document it?  etc.
> 
> You know what I'm saying ;)  What is the proposed interface?

So, I'm not Michael, but I *did* make an attempt to document this
interface - user and kernel sides - so that it could be more easily
understood:

	http://lwn.net/Articles/276856/

That was the previous posting, but a quick look suggests it hasn't
changed *that* much in this round.

jon
