From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH] net: 8139too netdev_priv conversion
Date: Wed, 27 Oct 2004 16:07:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027140749.GA31398@gareth.mathematik.tu-chemnitz.de>
References: <1098872973.9269.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Disposition: inline
In-Reply-To: <1098872973.9269.1.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 27, 2004 at 01:29:32PM +0300 or thereabouts, Pekka Enberg wrote:
> Hi,
> 
> Use netdev_priv() in 8139too driver instead of dev->priv.

Stephen Hemminger actually did a patch to do just that.
Look at the netdev list.

Steffen
