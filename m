From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH,RFC] [NET] ALIGN
Date: Wed, 11 Feb 2004 10:42:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211104224.0e3a0357.davem@redhat.com>
References: <20040209.134528.28683257.yoshfuji@linux-ipv6.org>
	<20040209112007.08023ba6.davem@redhat.com>
	<20040210.130543.130923643.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040210.130543.130923643.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 10 Feb 2004 13:05:43 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20040209112007.08023ba6.davem@redhat.com> (at Mon, 9 Feb 2004 11:20:07 -0800), "David S. Miller" <davem@redhat.com> says:
> 
> > I think this is complete nonsense, and that the alignment is not
> > necessary.  I can't even come up with a performance reason as SLAB
> > is going to align things to hw cache line size anyways.
> 
> Agreed.

Patch applied, arigato Yoshfuji-san.
