From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 4/9] ehea: make things static
Date: Fri, 25 Apr 2008 02:03:13 -0400
Message-ID: <48117421.2010902@garzik.org>
References: <200804182050.m3IKodYj014830@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, osstklei@de.ibm.com, tklein@de.ibm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58525 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758068AbYDYGDS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:03:18 -0400
In-Reply-To: <200804182050.m3IKodYj014830@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> ehea_flush_sq() and ehea_purge_sq() should be static.
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Thomas Klein <osstklei@de.ibm.com>
> Cc: Thomas Klein <tklein@de.ibm.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 

applied


