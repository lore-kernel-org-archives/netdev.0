From: "David S. Miller" <davem@davemloft.net>
Subject: Re: race in net/ipv4/ipip.c ?
Date: Thu, 13 Jan 2005 20:54:07 -0800
Message-ID: <20050113205407.13154ccd.davem@davemloft.net>
References: <20050112125336.GH26856@postel.suug.ch>
	<20050112.220816.56650893.yoshfuji@linux-ipv6.org>
	<20050112132126.GI26856@postel.suug.ch>
	<20050112.223600.09187852.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: tgraf@suug.ch, buytenh@wantstofly.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050112.223600.09187852.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 Jan 2005 22:36:00 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> David, I think we need to fix sit.c, anyway.
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Good catch, I will apply this patch.
