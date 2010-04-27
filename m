From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: Properly display 1 gig downshift
 warning for backplane
Date: Tue, 27 Apr 2010 09:54:28 -0700 (PDT)
Message-ID: <20100427.095428.27807044.davem@davemloft.net>
References: <20100427103724.23338.53872.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, anjali.singhai@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52184
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751539Ab0D0QyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 12:54:25 -0400
In-Reply-To: <20100427103724.23338.53872.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Not fixing a regression, not fixing a catastropic error, just adding
a warning message.

Therefore not appropriate for net-2.6
