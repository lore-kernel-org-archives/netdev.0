From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 3/3] use SLAB_ALIGN_SMP
Date: Mon, 3 Mar 2008 12:12:15 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803031211100.16049@schroedinger.engr.sgi.com>
References: <20080303093449.GA15091@wotan.suse.de> <20080303093624.GC15091@wotan.suse.de>
 <47CBCAB0.2040604@cosmosbay.com> <20080303124142.GB13138@wotan.suse.de>
 <47CBF683.10201@cosmosbay.com> <20080303134622.GD13138@wotan.suse.de>
 <84144f020803030553s35a40dd8yf88585ccd5a599fd@mail.gmail.com>
 <Pine.LNX.4.64.0803031109200.6917@schroedinger.engr.sgi.com>
 <20080303201008.GD8974@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>
To: Nick Piggin <npiggin@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758348AbYCCUMu@vger.kernel.org>
In-Reply-To: <20080303201008.GD8974@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 3 Mar 2008, Nick Piggin wrote:

> Yeah, that's what I thought too, when I got confused by these new
> SLUB semantics that you made up. Actually if you look at SLAB,
> it has very precise and rational semantics. SLUB should respect that.

These crappy semantics are SLAB semantics that SLUB must support.
