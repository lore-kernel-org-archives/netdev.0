From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Remove debug printk
Date: Tue, 14 Apr 2009 16:53:32 -0700 (PDT)
Message-ID: <20090414.165332.266864546.davem@davemloft.net>
References: <1225849876-8930-3-git-send-email-fubar@us.ibm.com>
	<49E518F8.3030109@siriusit.co.uk>
	<8409.1239753109@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: duncan.gibb@siriusit.co.uk, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60344
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751801AbZDNXxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 19:53:41 -0400
In-Reply-To: <8409.1239753109@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 14 Apr 2009 16:51:49 -0700

> 
> 	Remove debug printk I accidently left in as part of commit:
> 
> commit 6146b1a4da98377e4abddc91ba5856bef8f23f1e
> Author: Jay Vosburgh <fubar@us.ibm.com>
> Date:   Tue Nov 4 17:51:15 2008 -0800
> 
>     bonding: Fix ALB mode to balance traffic on VLANs
> 
> 	Reported by Duncan Gibb <duncan.gibb@siriusit.co.uk>
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied and queued up for 2.6.29-stable
