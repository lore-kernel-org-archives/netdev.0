From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] random: remove TCP MD4 code if !CONFIG_INET
Date: Thu, 18 Nov 2004 14:32:18 -0800
Message-ID: <20041118143218.19f90b0e.davem@davemloft.net>
References: <20041117152116.6934bfa9@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041117152116.6934bfa9@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Nov 2004 15:21:16 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> The code in the random driver for tcp sequence number randomization
> is only needed if INET is configured.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
