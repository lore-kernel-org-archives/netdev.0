From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] SIT tunnels over IPsec
Date: Mon, 19 Jan 2004 21:19:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119211921.2b213ee1.davem@redhat.com>
References: <40082F88.9030705@logix.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ludvig <michal@logix.cz>
In-Reply-To: <40082F88.9030705@logix.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 16 Jan 2004 19:38:00 +0100
Michal Ludvig <michal@logix.cz> wrote:

> The attached patch fixes IPv6-in-IPv4 (SIT) tunnel over IPsec. Without 
> it the SIT packets originated from the same host as the IPsec endpoint 
> is leave the interface unencrypted and of course the tunnel doesn't 
> work. The patch fixes it. Tested.
> 
> Please apply.

Applied, thanks Michal.
