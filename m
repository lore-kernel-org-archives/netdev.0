From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Best way to hook incoming eth pkts?
Date: Wed, 20 Aug 2003 13:59:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820175929.GD23984@gtf.org>
References: <20030820154727.GB9119@gtf.org> <6756.1061401768@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Content-Disposition: inline
In-Reply-To: <6756.1061401768@marajade.sandelman.ottawa.on.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Aug 20, 2003 at 01:49:28PM -0400, Michael Richardson wrote:
>   For ethernet protocols, you can just register the protocol handler, and you
> will get them.

Dumb question:  how?  example code, or relevant functions to grep for?

grepping for 'register.*prot' didn't seem to turn up anything useful,
and I didn't see any register*ether functions in linux/if_ether.h.

Thanks,

	Jeff
