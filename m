From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] remove dead extern's in netdevice.h
Date: Wed, 9 Mar 2005 21:14:52 -0800
Message-ID: <20050309211452.40ed9d8e.davem@davemloft.net>
References: <20050302105902.72f2b983@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050302105902.72f2b983@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2 Mar 2005 10:59:02 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> The following definitions are historical relics.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Good catch, I missed this when we ripped out the hw flow
control stuff.

Applied, thanks Stephen.
