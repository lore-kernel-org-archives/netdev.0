From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] drivers/atm/solos-pci.c: fix warning/bug, clean up
 code
Date: Wed, 18 Nov 2009 05:07:26 -0800 (PST)
Message-ID: <20091118.050726.189437981.davem@davemloft.net>
References: <200911172246.nAHMkiK2004221@imap1.linux-foundation.org>
	<1258498555.6132.71.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil, nathan@traverse.com.au
To: david.woodhouse@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53245
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753293AbZKRNHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 08:07:09 -0500
In-Reply-To: <1258498555.6132.71.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <david.woodhouse@intel.com>
Date: Tue, 17 Nov 2009 22:55:55 +0000

> On Tue, 2009-11-17 at 14:46 -0800, akpm@linux-foundation.org wrote:
>> From: Andrew Morton <akpm@linux-foundation.org>
>> 
>> drivers/atm/solos-pci.c: In function 'flash_upgrade':
>> drivers/atm/solos-pci.c:528: warning: 'fw_name' may be used uninitialized in this function
>> 
>> Cc: Chas Williams <chas@cmf.nrl.navy.mil>
>> Cc: Nathan Williams <nathan@traverse.com.au>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Acked-By: David Woodhouse <David.Woodhouse@intel.com>

Applied to net-next-2.6
