From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 2/3] IPV6: unify 3 similar code path in ndisc_recv_ns()
Date: Sat, 7 Feb 2004 03:17:53 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040207051753.GC25484@conectiva.com.br>
References: <20040206.181006.79694138.yoshfuji@linux-ipv6.org> <20040206153201.126c88b8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040206153201.126c88b8.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Fri, Feb 06, 2004 at 03:32:01PM -0800, David S. Miller escreveu:
> On Fri, 06 Feb 2004 18:10:06 +0900 (JST)
> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:
> 
> > [PATCH 2/3] IPV6: unify 3 similar code path in ndisc_recv_ns()
> > 
> > D: Unify 3 similar code path in ndisc_recv_ns().
> > D: This patch also fixes:
> > D:  - flags sent with NA in reply to this NS
> > D:  - missing random delay after receipt of NS against anycast
> 
> Very nice consolidation of code.

Indeed, I'm out of the game for a while, swamped in distro work, but don't
worry... I'll be back! :-P

- Arnaldo
