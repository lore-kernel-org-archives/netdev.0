From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/6] [TULIP]  From: Jim Gifford <maillist@jg555.com>,
 Grant Grundler <grundler@parisc-linux.org>, Peter Horton <pdh@colonel-panic.org>
Date: Thu, 15 Mar 2007 11:20:19 -0400
Message-ID: <45F96433.7030504@garzik.org>
References: <20070312093128.577087000@linux.intel.com> <20070312184216.848494000@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Valerie Henson <val_henson@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50338 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422886AbXCOPUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 11:20:24 -0400
In-Reply-To: <20070312184216.848494000@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valerie Henson wrote:
> With Grant's help I was able to get the tulip driver to work with 64 bit 
> MIPS.
> 
> [VAL: I'm happy with the 1.5 ms max delay; it doesn't seem excessive.]
> 
> Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> ---
> 
>  drivers/net/tulip/media.c |   22 ++++++++++++++++++++--
>  drivers/net/tulip/tulip.h |    7 +++++--
>  2 files changed, 25 insertions(+), 4 deletions(-)

applied 1-2, after fixing the subject line as discussed


