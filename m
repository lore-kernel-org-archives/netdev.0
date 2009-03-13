From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ehea: fix circular locking problem
Date: Fri, 13 Mar 2009 13:50:48 -0700 (PDT)
Message-ID: <20090313.135048.202553524.davem@davemloft.net>
References: <200903121620.19075.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	raisch@de.ibm.com, tklein@de.ibm.com, themann@de.ibm.com,
	hering2@de.ibm.com, linuxppc-dev@ozlabs.org
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48913
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753451AbZCMUvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 16:51:02 -0400
In-Reply-To: <200903121620.19075.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan-Bernd Themann" <ossthema@de.ibm.com>
Date: Thu, 12 Mar 2009 16:20:18 +0100

> This patch fixes the circular locking problem by changing the locking strategy
> concerning the logging of firmware handles.
> 
> Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

Applied, thanks.
