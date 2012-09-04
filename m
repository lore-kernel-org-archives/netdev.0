From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2] fq_codel : interval servo on hosts
Date: Tue, 04 Sep 2012 18:54:06 +0200
Message-ID: <1346777646.13121.46.camel@edumazet-glaptop>
References: <1346396137.2586.301.camel@edumazet-glaptop>
	<1346421031.2591.34.camel@edumazet-glaptop>
	<1346421466.2591.38.camel@edumazet-glaptop>
	<CAK6E8=cwpq0MVK6fcrOa=wTX237xQiVP2xzh0aX-AtuSmzt-sw@mail.gmail.com>
	<1346503884.7996.65.camel@edumazet-glaptop>
	<CAB_+Fg5xPRqEZNdH0mYogmm4LitMvycSLB-X1_7ryn4RY9FvSA@mail.gmail.com>
	<1346772855.13121.40.camel@edumazet-glaptop>
	<CAA93jw6k4pgwanTa81oHb8jV6WGMfoo6KuOBSjbrfU3eRMbt5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tomas Hruby <thruby@google.com>, Nandita Dukkipati <nanditad@google.com>,
	netdev <netdev@vger.kernel.org>, codel@lists.bufferbloat.net
To: Dave Taht <dave.taht@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAA93jw6k4pgwanTa81oHb8jV6WGMfoo6KuOBSjbrfU3eRMbt5A@mail.gmail.com>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Tue, 2012-09-04 at 09:40 -0700, Dave Taht wrote:

> >
> > Well, how things settle with a pure codel, mixing flows of very
> > different RTT then ?
> 
> Elephants are shot statistically more often than mice.

This doesnt answer the question.

long/short RTT have nothing to do with elephant and mice.
