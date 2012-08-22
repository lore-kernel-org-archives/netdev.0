From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/3] netfilter: replace list_for_each_continue_rcu with
 new interface
Date: Thu, 23 Aug 2012 00:32:28 +0200
Message-ID: <20120822223228.GA11141@1984>
References: <502CB939.3050008@linux.vnet.ibm.com>
 <502DC9A3.2070703@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <502DC9A3.2070703@linux.vnet.ibm.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 17, 2012 at 12:33:39PM +0800, Michael Wang wrote:
> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> 
> This patch replaces list_for_each_continue_rcu() with
> list_for_each_entry_continue_rcu() to allow removing
> list_for_each_continue_rcu().

Applied, thanks.
