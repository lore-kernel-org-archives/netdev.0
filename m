From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: crash in fib_hash_move
Date: Fri, 17 Sep 2004 14:51:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917185106.GA22810@havoc.gtf.org>
References: <20040917114249.7449b9ff@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040917114249.7449b9ff@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 17, 2004 at 11:42:49AM -0700, Stephen Hemminger wrote:
> Current 2.6 tree is crashing on bootup in fib code.
> Looks like recent FIB changes problem.

Yeah, David Gibson already posted a fix, see
"[TRIVIAL] Fix recent bug in fib_semantics.c"

	Jeff
