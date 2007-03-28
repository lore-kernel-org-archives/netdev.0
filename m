From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 07/10] SUN3/3X Lance trivial fix improved
Date: Wed, 28 Mar 2007 02:19:35 -0400
Message-ID: <460A08F7.3020105@garzik.org>
References: <200703270547.l2R5lQco008269@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gorcunov@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42327 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933618AbXC1GTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 02:19:37 -0400
In-Reply-To: <200703270547.l2R5lQco008269@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: "Cyrill V. Gorcunov" <gorcunov@gmail.com>
> 
> This patch adds checking for allocated DVMA memory and granted IRQ line.
> 
> Signed-off-by: Cyrill V. Gorcunov <gorcunov@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

applied to #upstream-fixes


