From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 0/4] arch: Add lightweight memory barriers for
 coherent memory access
Date: Thu, 11 Dec 2014 15:32:04 -0500 (EST)
Message-ID: <20141211.153204.228153607927530694.davem@davemloft.net>
References: <20141125203310.8240.27370.stgit@ahduyck-server>
	<54892B87.3020909@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, linux-arch@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	arnd@arndb.de, mathieu.desnoyers@polymtl.ca, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	mingo@kernel.org, mikey@neuling.org, linux@arm.linux.org.uk,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	geert@linux-m68k.org, jeffrey.t.kirsher@intel.com,
	romieu@fr.zoreil.com, paulmck@linux.vnet.ibm.com,
	nic_swsd@realtek.com, will.deacon@arm.com, michael@ellerman.id.au,
	tony.luck@intel.com, torvalds@linux-foundation.org,
	oleg@redhat.com, schwidefsky@de.ibm.com, fweisbec@gmail.com
To: alexander.duyck@gmail.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <54892B87.3020909@gmail.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 10 Dec 2014 21:28:39 -0800

> It occurs to me that I never got a sign off from any of the maintainers
> on getting this pulled in.
> 
> Since the merge window is open I was wondering which tree I should make
> sure these patches apply to and who will be the one to pull them in?
> Since I was modifying network drivers should I resubmit them for netdev,
> or should I submit them for asm-generic or some other tree?

I have no problem taking this via my tree, but I want to see agreement
from other interested parties.
