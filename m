From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 1/4] net: change sysctl_net_ll_poll into an
 unsigned int
Date: Thu, 13 Jun 2013 20:03:19 -0700
Message-ID: <1371178999.3252.113.camel@edumazet-glaptop>
References: <20130614015638.3500.61523.stgit@ladj378.jer.intel.com>
	 <20130614015648.3500.85865.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Avner Ben Hanoch <avnerb@mellanox.com>,
	Or Kehati <ork@mellanox.com>, sockperf-dev@googlegroups.com,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130614015648.3500.85865.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-06-14 at 04:56 +0300, Eliezer Tamir wrote:
> There is no reason for sysctl_net_ll_poll to be an unsigned long.
> Change it into an unsigned int.
> Fix the proc handler.
> 
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
