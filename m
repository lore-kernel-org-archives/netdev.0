From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 51/51] net/iucv/iucv.c: Fix CPU hotplug callback
 registration
Date: Thu, 06 Feb 2014 21:19:40 -0800 (PST)
Message-ID: <20140206.211940.1004239821350436139.davem@davemloft.net>
References: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com>
	<20140205221354.19080.25861.stgit@srivatsabhat.in.ibm.com>
	<20140206.203935.23931642792292899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, oleg@redhat.com, rusty@rustcorp.com.au,
	peterz@infradead.org, tglx@linutronix.de,
	akpm@linux-foundation.org, mingo@kernel.org,
	paulmck@linux.vnet.ibm.com, tj@kernel.org, walken@google.com,
	ego@linux.vnet.ibm.com, linux@arm.linux.org.uk,
	linux-kernel@vger.kernel.org, ursula.braun@de.ibm.com,
	linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: srivatsa.bhat@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140206.203935.23931642792292899.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 06 Feb 2014 20:39:35 -0800 (PST)

> Applied.

I just realized that this has a dependency not in the 'net'
tree, so I reverted and assume you will merge this with the
patch that provides the necessary interface(s).

Signed-off-by: David S. Miller <davem@davemloft.net>
