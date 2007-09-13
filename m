From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] Nuke SET_MODULE_OWNER macro
Date: Thu, 13 Sep 2007 00:07:58 -0400
Message-ID: <46E8B79E.9060304@garzik.org>
References: <20070912164036.GB9615@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52902 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334AbXIMEH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 00:07:59 -0400
In-Reply-To: <20070912164036.GB9615@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> It's been a useless no-op for long enough in 2.6 so I figured it's time to
> remove it.  The number of people that could object because they're
> maintaining unified 2.4 and 2.6 drivers is probably rather small.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

applied


