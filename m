From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Missing break in switch statement.
Date: Mon, 11 Aug 2003 22:26:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030811222633.13f6759c.davem@redhat.com>
References: <E19mFqr-00068T-00@tetrachloride>
	<20030812.021414.128414948.yoshfuji@hongo.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki <yoshfuji@hongo.wide.ad.jp>
In-Reply-To: <20030812.021414.128414948.yoshfuji@hongo.wide.ad.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Aug 2003 02:14:14 +0900 (JST)
YOSHIFUJI Hideaki <yoshfuji@hongo.wide.ad.jp> wrote:

> In article <E19mFqr-00068T-00@tetrachloride> (at Mon, 11 Aug 2003 17:48:57 +0100), davej@redhat.com says:
> 
> > Is this intentional? It should at least have a 
> > /* FALLTHROUGH */ or similar if so.
> 
> Of course not.

Patch applied, thanks David.
