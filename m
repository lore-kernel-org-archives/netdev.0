From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2/3] IPV6: unify 3 similar code path in ndisc_recv_ns()
Date: Fri, 6 Feb 2004 15:32:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206153201.126c88b8.davem@redhat.com>
References: <20040206.181006.79694138.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040206.181006.79694138.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 06 Feb 2004 18:10:06 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> [PATCH 2/3] IPV6: unify 3 similar code path in ndisc_recv_ns()
> 
> D: Unify 3 similar code path in ndisc_recv_ns().
> D: This patch also fixes:
> D:  - flags sent with NA in reply to this NS
> D:  - missing random delay after receipt of NS against anycast

Very nice consolidation of code.

Applied, thanks Yoshfuji.
