From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUG] 2.6.3 + hp100 -> Oops
Date: Wed, 18 Feb 2004 12:26:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040218122601.56e47118@dell_ss3.pdx.osdl.net>
References: <20040218201559.GA31872@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Linux kernel mailing list
 <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040218201559.GA31872@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 18 Feb 2004 12:15:59 -0800
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

> 	Hi,
> 
> 	Maybe it would be a good idea to fix or revert the hp100 patch
> that went into 2.6.3 :

Modular or non-modular?  There seems to be a lot of debug stuff in the driver,
could you enable it and see where it hiccup'd.
