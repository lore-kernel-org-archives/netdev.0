From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipv6 UDP MSG_MORE oops fix
Date: Sun, 26 Oct 2003 23:56:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031026235657.7c3927d5.davem@redhat.com>
References: <20030807223421.70497d61.davem@redhat.com>
	<20030808.170839.90822982.yoshfuji@linux-ipv6.org>
	<20031026.185023.108406592.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org,
        miyazawa@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031026.185023.108406592.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 26 Oct 2003 18:50:23 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> [1/3] IPv6: Odd IPv6 header in UDPv6 packets when sending MSG_MORE flag
> [2/3] NET: store cork'ing flow information in common storage in inet_opt
> [3/3] IPv6: breakage of sendmsg to IPv4-mapped address via UDPv6 socket

All three patches applied, thanks Yoshfuji.
