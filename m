From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 02/29] mm: slab allocation fairness
Date: Wed, 21 Feb 2007 17:33:31 +0200
Message-ID: <84144f020702210733s4576076cw7e9a2257d28b278b@mail.gmail.com>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
	 <20070221144841.751839000@taijtu.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Thomas Graf" <tgraf@suug.ch>, "David Miller" <davem@davemloft.net>
To: "Peter Zijlstra" <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965372AbXBUPdg@vger.kernel.org>
In-Reply-To: <20070221144841.751839000@taijtu.programming.kicks-ass.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/21/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> [AIM9 results go here]

Yes please. I would really like to know what we gain by making the
slab even more complex.
