From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] pktgen - handle NETDEV_TX_LOCKED
Date: Thu, 23 Sep 2004 13:08:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923130859.4e6c0502.davem@redhat.com>
References: <20040922141158.3a16416c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040922141158.3a16416c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 14:11:58 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Change pktgen to handle drivers that return TX_LOCKED better.
> This isn't a real busy state so just spin.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
