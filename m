From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: redo stateless addrconf properly
Date: Tue, 25 Nov 2003 17:09:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125170942.7bef08fe.davem@redhat.com>
References: <20031125.224037.85040739.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031125.224037.85040739.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Nov 2003 22:40:37 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> Interface that had configured via stateless addrconf did not do 
> stateless addrconf again correctly after interface was down.
> Forget IF_RS_SENT|IF_RA_RCVD flags when interface goes down.
> 
> Patch is against 2.6.0-test10, but similar logic applies to
> 2.4.x and 2.2.x.

Applied, arigato Yoshfuji.
