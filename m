From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] remove useless MOD_{INC,DEC}_USE_COUNT
Date: Tue, 11 May 2004 03:07:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40A07BC0.20906@pobox.com>
References: <20040507104311.GA10873@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040507104311.GA10873@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> *grr* - this one slipped in after my last round of audits it seems.
> 
> 
> --- 1.15/drivers/net/gt96100eth.c	Mon Apr  5 22:31:23 2004
> +++ edited/drivers/net/gt96100eth.c	Mon May  3 13:22:22 2004


applied
