From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] defxx: Use __maybe_unused rather than a local hack
Date: Tue, 24 Jul 2007 16:37:18 -0400
Message-ID: <46A662FE.3050001@pobox.com>
References: <Pine.LNX.4.64N.0707201310060.7402@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59027 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762345AbXGXUht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 16:37:49 -0400
In-Reply-To: <Pine.LNX.4.64N.0707201310060.7402@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
>  This is a change to remove a local hack in favour to __maybe_unused that 
> has been recently added.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
> Hi,
> 
>  It should be obvious.  The code builds, therefore it works.
> 
>  Please apply,
> 
>   Maciej
> 

applied


