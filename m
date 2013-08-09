From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: rename busy poll MIB counter
Date: Fri, 09 Aug 2013 11:39:40 -0700 (PDT)
Message-ID: <20130809.113940.187893351073333334.davem@davemloft.net>
References: <20130807083324.27322.99300.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbohrer@rgmadvisors.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130807083324.27322.99300.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Wed, 07 Aug 2013 11:33:25 +0300

> Rename mib counter from "low latency" to "busy poll"
> 
> v1 also moved the counter to the ip MIB (suggested by Shawn Bohrer)
> Eric Dumazet suggested that the current location is better.
> 
> So v2 just renames the counter to fit the new naming convention.
> 
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>

Applied, thanks.
