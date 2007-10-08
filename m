From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/2] [AF_IUCV] fixes for net-2.6.24 - cleanup resend
Date: Mon, 08 Oct 2007 02:03:51 -0700 (PDT)
Message-ID: <20071008.020351.69386126.davem@davemloft.net>
References: <20071008085119.805528000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	heicars2@linux.vnet.ibm.com
To: braunu@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51488
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752591AbXJHJDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 05:03:52 -0400
In-Reply-To: <20071008085119.805528000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>
Date: Mon, 08 Oct 2007 10:51:19 +0200

> -- 
> Dave,
> 
> this is the resend of my patches from last week built against net-2.6.24.
> 
> > the following 2 patches are intended for 2.6.24 and contain:
> > - removal of static declarations in af_iucv header file
> > - postpone receival of inbound packets in af_iucv

All applied, thanks!
