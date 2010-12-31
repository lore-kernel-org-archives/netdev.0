From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2 0/3] Series short description
Date: Fri, 31 Dec 2010 10:49:41 -0800 (PST)
Message-ID: <20101231.104941.189703153.davem@davemloft.net>
References: <20101230192449.21487.9764.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lucy.liu@intel.com, shmulikr@broadcom.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55649
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750923Ab0LaStK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 13:49:10 -0500
In-Reply-To: <20101230192449.21487.9764.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Thu, 30 Dec 2010 11:25:40 -0800

> Version 2 adds the recommended tlv attributes to the ets struct this will
> be needed for offloaded LLDP engines. Host controlled LLDP agents will most
> likely not use these fields.
> 
> Also Shmulik Ravid caught an error with a spin_lock on kmalloc failure.

BTW, even though I replied "applied" to v1 of these patches I made
sure to actully apply v2 :-)
