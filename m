From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4,IPV6] UDPv6: use udpv6_queue_rcv_skb().
Date: Tue, 15 Jun 2004 21:09:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615210956.332632d2.davem@redhat.com>
References: <20040616.001016.54016316.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040616.001016.54016316.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jun 2004 00:10:16 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Use udpv6_queue_rcv_skb() instead of sock_queue_rcv_skb()
> as we do in 2.6 for checksum, (ipsec and) statistics.

Applied, thanks.
