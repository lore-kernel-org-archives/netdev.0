From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] Tcp port selection for IPV6.
Date: Thu, 20 Jan 2005 22:53:18 -0200
Message-ID: <39e6f6c705012016537fa48ca4@mail.gmail.com>
References: <20050120164529.6d6a5f0b@dxpl.pdx.osdl.net>
Reply-To: acme@ghostprotocols.net
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050120164529.6d6a5f0b@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 20 Jan 2005 16:45:29 -0800, Stephen Hemminger
<shemminger@osdl.org> wrote:

> Now the code in ipv4/tcp_ipv4.c and ipv6/tcp_ipv6.c are
> almost identical for tcp_hash_connect.

Humm,  dccp_hash_connect is almost identical to tcp_hash_connect too...  /me
adds an entry to his TODO list... :-)

- Arnaldo
