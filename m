From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [APPLETALK]: Use '%Z' for size_t.
Date: Thu, 19 Feb 2004 18:50:15 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1077216615.7832.3.camel@imladris.demon.co.uk>
References: <200402190209.i1J29KF2020707@hera.kernel.org>
	 <1077204436.18703.412.camel@hades.cambridge.redhat.com>
	 <20040219100914.1a17e797.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040219100914.1a17e797.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-02-19 at 10:09 -0800, David S. Miller wrote:
> As long as lib/vsprintf.c in the kernel supports it, there is no reason not
> to use it.  They're never going to remove recognition of this thing from
> gcc printf's parsing.
> 
> If it really bothers you, then go sick a kernel janitor onto it, because there
> are thousands of uses of %Z, I know because I put most of them into the tree :-)

Never's a long time.... the request was that you refrain from putting
_new_ ones in. That's not so hard, now is it?

-- 
dwmw2
