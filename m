From: "David S. Miller" <davem@davemloft.net>
Subject: Re: network speed extremly slowed down
Date: Mon, 14 Mar 2005 12:15:09 -0800
Message-ID: <20050314121509.70dcd129.davem@davemloft.net>
References: <200503141745.08032.bernd.schubert@pci.uni-heidelberg.de>
	<20050314115757.789a82d4@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bernd.schubert@pci.uni-heidelberg.de, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050314115757.789a82d4@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Mar 2005 11:57:57 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Are there any errors reported? Cpu time sees high perhaps the console log
> is filling with messages or something.

Or he has CONFIG_DEBUG_SLAB enabled in his kernel config.
So many people do this unknowingly.
