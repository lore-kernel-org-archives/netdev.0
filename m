From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.10] tg3: Fix TSO for 5750
Date: Mon, 24 Jan 2005 18:05:15 -0800
Message-ID: <20050124180515.6f288742.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3D44@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3D44@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 24 Jan 2005 14:59:43 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> > Here, just checking the TG3_FLG3_HW_TSO flag would suffice.
> 
> This particular test is for 5705 or 5750. 5705 is a little different from
> 5750 in terms of TSO.

You are right, I transposed 5705 and 5750 while reading the diff.

I'll apply your patch right away Michael, thanks a lot.
