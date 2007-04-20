From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2.6.20] networking: bonding documentation fix for multiple bonding interfaces
Date: Fri, 20 Apr 2007 09:12:11 -0700
Message-ID: <32493.1177085531@death>
References: <20070417074956.GA20123@oktetlabs.ru>
Cc: lkml@vger.kernel.org, netdev@vger.kernel.org, akpm@osdl.org
To: "Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:44194 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993015AbXDTQMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 12:12:16 -0400
In-reply-to: <20070417074956.GA20123@oktetlabs.ru> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexandra N. Kossovsky <Alexandra.Kossovsky@oktetlabs.ru> wrote:

>Fix bonding driver documentation for the case of multiple bonding interfaces.
>
>Signed-off-by: "Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>

	I don't see a problem with this; users running distros that
require the multiple load fru fru still have the documentation supplied
with their distro kernel.

Acked-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
