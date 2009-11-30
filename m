From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/5] slab.c: remove branch hint
Date: Mon, 30 Nov 2009 11:50:15 -0600 (CST)
Message-ID: <alpine.DEB.2.00.0911301149110.17037@router.home>
References: <cover.1259059549.git.tim@klingt.org> <4B0BBBA8.2090604@klingt.org>  <20091124112058.GA23765@elte.hu>  <84144f020911240328l3d36d347o6c91b2b1a0f50f2a@mail.gmail.com>  <4B125CC2.7000202@klingt.org> <4B138AC2.7080008@cs.helsinki.fi>
 <alpine.DEB.2.00.0911300926150.14098@router.home> <84144f020911300944x89309c5r8e9079e1a62fb416@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tim Blechmann <tim@klingt.org>, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753200AbZK3Rud@vger.kernel.org>
In-Reply-To: <84144f020911300944x89309c5r8e9079e1a62fb416@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Nov 2009, Pekka Enberg wrote:

> Tim, can you please re-send the patch to me so I can apply it?

SLUB has no issue since NUMA decisions are deferred to the page allocator.
