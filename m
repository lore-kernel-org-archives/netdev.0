From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.9]: Fix netdevice/inet6_dev reference leaks in
 ip6_route_add error paths
Date: Wed, 20 Oct 2004 21:22:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020212213.3ff8fc1f.davem@davemloft.net>
References: <417591A2.4090201@trash.net>
	<20041020.153525.50629727.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20041020.153525.50629727.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Oct 2004 15:35:25 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <417591A2.4090201@trash.net> (at Wed, 20 Oct 2004 00:13:54 +0200), Patrick McHardy <kaber@trash.net> says:
> 
> > The recent changes to ip6_route_add added multiple leaks in
> > error paths. This patch should fix them.
> 
> Agreed. David, please apply.
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Applied, thanks everyone.
