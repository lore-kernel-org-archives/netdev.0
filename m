From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Where is netif_rx() not safe to use?
Date: Mon, 12 May 2003 10:59:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030512145943.GB27111@gtf.org>
References: <3ebfa567b38e59.35614148@not right>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
Content-Disposition: inline
In-Reply-To: <3ebfa567b38e59.35614148@not right>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 12, 2003 at 03:45:11PM +0200, Rask Ingemann Lambertsen wrote:
> 
> Hi.
> 
> I'd like to know if there are situations where netif_rx() is not safe to use. 
> For example, is it safe to call from a timer or from dev->poll()?

Sure, that's fine.

	Jeff
