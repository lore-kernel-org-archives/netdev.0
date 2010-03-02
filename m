From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] ppp: Bridge Control Protocol
Date: Mon, 1 Mar 2010 20:42:08 -0800
Message-ID: <20100301204208.36f81443@s6510>
References: <20100301145915.2ecaac89@nehalam>
	<20100302033944.GL26848@brick.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David@mail.vyatta.com, "Miller <davem"@davemloft.net,
	linux-ppp@vger.kernel.org, bridge@linux-foundation.org,
	netdev@vger.kernel.org, dane@aiinet.com
To: Paul Mackerras <paulus@samba.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20100302033944.GL26848@brick.ozlabs.ibm.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 Mar 2010 14:39:44 +1100
Paul Mackerras <paulus@samba.org> wrote:

> On Mon, Mar 01, 2010 at 02:59:15PM -0800, Stephen Hemminger wrote:
> 
> > This is a port of an old patch to provide BCP support.
> > BCP allows bridging PPP tunnels, it useful to do bridging between
> > virtualized environments. Original patch was done by
> > Dan Eble but was for 2.4.21.
> > 
> > Note: still needs testing. Does anyone have hardware to make
> > sure this interoperates with other implementations?
> 
> Is there a corresponding pppd patch to handle the control protocol?
> 
> Paul.

Old starting point

https://lists.linux-foundation.org/pipermail/bridge/2005-May/004523.html
