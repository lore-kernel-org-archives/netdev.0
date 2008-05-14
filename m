From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/8] iphase: fix 64bit warning
Date: Wed, 14 May 2008 16:42:12 -0700 (PDT)
Message-ID: <20080514.164212.243580407.davem@davemloft.net>
References: <200805142319.m4ENJdEQ026549@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk, alan@redhat.com,
	chas@cmf.nrl.navy.mil, jeff@garzik.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42328
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753646AbYENXmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:42:17 -0400
In-Reply-To: <200805142319.m4ENJdEQ026549@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 14 May 2008 16:19:39 -0700

> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> 
> Time is unsigned long (except when you are in a hurry) so we need to store
> rx_tmp_jif in the right sized object.
> 
> Signed-off-by: Alan Cox <alan@redhat.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: chas williams <chas@cmf.nrl.navy.mil>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: David S. Miller <davem@davemloft.net>
