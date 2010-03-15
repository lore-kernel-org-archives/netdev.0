From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/5] obsolete config in kernel source: HSO_AUTOPM
Date: Mon, 15 Mar 2010 16:06:02 -0700 (PDT)
Message-ID: <20100315.160602.06558560.davem@davemloft.net>
References: <201003112207.o2BM7sbR013498@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, siccegge@stud.informatik.uni-erlangen.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42729
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937101Ab0COXFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 19:05:40 -0400
In-Reply-To: <201003112207.o2BM7sbR013498@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 11 Mar 2010 14:07:54 -0800

> From: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
> 
> CONFIG_HSO_AUTOPM is set by KConfig / set in the Kernel source, makefiles
> and won't be ever set this way, therefor simply removing the protected
> code.
> 
> Signed-off-by: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
