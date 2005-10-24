From: Daniele Orlandi <daniele@orlandi.com>
Subject: Re: Request for an ARPHRD_
Date: Tue, 25 Oct 2005 00:58:23 +0200
Message-ID: <200510250058.24561.daniele@orlandi.com>
References: <200510240255.28416.daniele@orlandi.com> <200510250008.10409.daniele@orlandi.com> <20051024222222.GA11005@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@vger.kernel.org
In-Reply-To: <20051024222222.GA11005@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 25 October 2005 00:22, Lennert Buytenhek wrote:
>
> Your code might never end up in the kernel at all, for example if you
> ever lose interest in it.  The situation that we'd like to avoid is
> ending up with reserved constants for code that was never submitted
> upstream at all.

Okay, I see your point.

IMHO I'd have preferred a more open politic like libpcap's. There may be valid 
reasons to keep code out of the tree and this makes maintenance even harder 
to perform than it already is.

Thanks anyway,

Bye,

-- 
  Daniele Orlandi
