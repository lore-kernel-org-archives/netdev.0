From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.9]: Fix netdevice/inet6_dev reference leaks in
 ip6_route_add error paths
Date: Wed, 20 Oct 2004 22:17:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020221708.46689319.davem@davemloft.net>
References: <417591A2.4090201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <417591A2.4090201@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Oct 2004 00:13:54 +0200
Patrick McHardy <kaber@trash.net> wrote:

> The recent changes to ip6_route_add added multiple leaks in
> error paths. This patch should fix them.

Applied already, as mentioned in my response to Yoshifuji-san's
ACK of this patch.
