From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [BUG] 2.6.3 + hp100 -> Oops
Date: Wed, 18 Feb 2004 14:16:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040218221641.GA1182@bougret.hpl.hp.com>
References: <20040218201559.GA31872@bougret.hpl.hp.com> <20040218124034.05c9f6aa@dell_ss3.pdx.osdl.net>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040218124034.05c9f6aa@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Feb 18, 2004 at 12:40:34PM -0800, Stephen Hemminger wrote:
> 
> This should fix the problem... The multi-bus probe logic error handling was
> botched.

	Thanks. The driver now seems to works. However, the kernel
messages no longer show the device name...

	Thanks.

	Jean
