From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.11 5/8] tg3: Add unstable PLL workaround for 5750
Date: Wed, 23 Mar 2005 11:09:18 -0800
Message-ID: <20050323110918.460ff255.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3E25@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3E25@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 20 Mar 2005 23:48:13 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> Add unstable PLL clock workaround for 5750 Ax and Bx devices. The workaround
> code is run just before entering D3hot state.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
