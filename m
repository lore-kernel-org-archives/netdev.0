From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/6] e1000e: remove namespace collisions with e1000
Date: Tue, 14 Aug 2007 09:41:45 -0700
Message-ID: <46C1DB49.1080601@hp.com>
References: <20070810200038.21509.77815.stgit@localhost.localdomain>	<20070810200047.21509.46779.stgit@localhost.localdomain> <46C139F6.2040007@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, andi@firstfloor.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:39299 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764797AbXHNQmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 12:42:33 -0400
In-Reply-To: <46C139F6.2040007@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> if you grep around this effort was already started using the 'e1e_' 
> prefix.  I like the shorter prefix, but your call ultimately.  Either 
> way, make sure to make the driver consistent there too.

should it then be consistent with the overall driver name too? 
certainly calling things e1e or e1ke  or heck, even elke if one wanted 
to be a triffle playful would certainly help distinguish this driver 
from its grandfather.

rick jones
