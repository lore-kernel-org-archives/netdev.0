From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [METH] Don't use GFP_DMA for zone allocation.
Date: Sat, 25 Aug 2007 00:40:35 -0400
Message-ID: <46CFB2C3.6060403@garzik.org>
References: <20070815115316.GB5862@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42144 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755980AbXHYEkj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 00:40:39 -0400
In-Reply-To: <20070815115316.GB5862@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> IP32 doesn't even have a ZONE_DMA so no point in using GFP_DMA in any
> IP32-specific device driver.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

applied


