From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Fri, 12 Nov 2010 13:14:12 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1011121313001.16754@router.home>
References: <1288975980.2882.877.camel@edumazet-laptop> <20101105102038.53e36f9e.akpm@linux-foundation.org> <1288980046.2882.1054.camel@edumazet-laptop> <20101105110828.52f061b3.akpm@linux-foundation.org> <1288981224.2882.1105.camel@edumazet-laptop>
 <20101105112821.57f80481.akpm@linux-foundation.org> <1288984844.2665.52.camel@edumazet-laptop> <20101105195101.GC15561@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	Nick Piggin <npiggin@kernel.dk>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101105195101.GC15561@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


prefetchw() would be too much overhead?
