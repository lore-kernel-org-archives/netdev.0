From: David Miller <davem@davemloft.net>
Subject: Re: fix up misplaced inlines.
Date: Thu, 22 Mar 2007 12:28:12 -0700 (PDT)
Message-ID: <20070322.122812.102564812.davem@davemloft.net>
References: <20070322001828.GF9092@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33758
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933257AbXCVT2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:28:12 -0400
In-Reply-To: <20070322001828.GF9092@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Wed, 21 Mar 2007 20:18:28 -0400

> Turning up the warnings on gcc makes it emit warnings
> about the placement of 'inline' in function declarations.
> Here's everything that was under net/
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied, thanks a lot Dave.
