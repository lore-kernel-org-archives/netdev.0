From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.11 6/8] tg3: Fix jumbo frames phy settings
Date: Wed, 23 Mar 2005 11:11:40 -0800
Message-ID: <20050323111140.4faf1561.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3E26@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3E26@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2005 00:02:02 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> Fix jumbo frame settings on all copper phys that support jumbo frames by
> setting the fifo elasticity bit. This setting is for the phy's tx fifo to
> properly handle jumbo frames. Note that a similar jumbo frame fix for the
> phy's rx fifo was made to tg3 in the past.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
