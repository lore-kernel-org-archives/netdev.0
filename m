From: James Morris <jmorris@intercode.com.au>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Tue, 8 Oct 2002 20:28:49 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0210082026030.8854-100000@blackbird.intercode.com.au>
References: <20021008102137.GA10627@toey.sourcefrog.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Pool <mbp@samba.org>
In-Reply-To: <20021008102137.GA10627@toey.sourcefrog.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 8 Oct 2002, Martin Pool wrote:

> OK, let me know if there's anything else you need.  At a stretch I
> could install 2.2 on a non-VM machine.

Thanks, but I can at least partially reproduce the problem with a specific 
network configuration.  At this stage, I'd say the patch supplied is 
probably fine, but I'm taking some time to make sure I really understand 
what's happening.


- James
-- 
James Morris
<jmorris@intercode.com.au>
