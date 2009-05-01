From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: correct the cleanup in bond_create()
Date: Fri, 01 May 2009 15:35:36 -0700 (PDT)
Message-ID: <20090501.153536.194169374.davem@davemloft.net>
References: <20090501214422.GA16065@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60186
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752567AbZEAWfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:35:42 -0400
In-Reply-To: <20090501214422.GA16065@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 1 May 2009 23:44:23 +0200

> This patch makes the cleanup in bond_create nicer :) Also now the forgotten
> free_netdev is called.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks Jiri.
