From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Tue, 8 Mar 2005 19:42:29 -0800
Message-ID: <20050308194229.41c23707.davem@davemloft.net>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
	<1110334456.32556.21.camel@gaston>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@oss.sgi.com, linuxppc-embedded@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1110334456.32556.21.camel@gaston>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 09 Mar 2005 13:14:16 +1100
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> I'll have a closer look when I find some time, see if it makes sense to
> adapt sungem or not.

Especially because of the Broadcom PHYs I bet it doesn't.

Too many chips have to reset the MAC, or do other fancy stuff
when programming the PHY to make this genphy thing very useful.
