From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: remove redundant checks from
 bonding_store_slaves V2
Date: Wed, 02 Jun 2010 03:40:42 -0700 (PDT)
Message-ID: <20100602.034042.148569276.davem@davemloft.net>
References: <20100518154452.GE2878@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33774
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757601Ab0FBKkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 06:40:32 -0400
In-Reply-To: <20100518154452.GE2878@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 18 May 2010 17:44:53 +0200

> (it's actually the same as v1)
> 
> Remove checks that duplicates similar checks in bond_enslave.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
