From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] [PATCH 1/3] netpoll api
Date: Fri, 3 Oct 2003 09:09:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003070954.GE25013@wotan.suse.de>
References: <20031003014104.GR1897@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20031003014104.GR1897@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The second patch is an example of implementing the poll_controller
> hook needed to get a card to work with netpoll. Numerous other examples
> are in -mm and recent Red Hat kernels.

SuSE/UL kernels also have support for some chips.

-Andi
