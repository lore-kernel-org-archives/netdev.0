From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] br2684 - use try_module_get appropriately
Date: Wed, 21 Jul 2004 16:15:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040721161520.39541ccd.davem@redhat.com>
References: <20040628093317.218220fe@dell_ss3.pdx.osdl.net>
	<200407192136.i6JLa4QO028602@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
In-Reply-To: <200407192136.i6JLa4QO028602@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 19 Jul 2004 17:36:05 -0400
"chas williams (contractor)" <chas@cmf.nrl.navy.mil> wrote:

> In message <20040628093317.218220fe@dell_ss3.pdx.osdl.net>,Stephen Hemminger wr
> ites:
> >Either way, just an (void) try_module_get() is WRONG.
> 
> dave, please apply to 2.6  --thanks

Applied, thanks guys.
