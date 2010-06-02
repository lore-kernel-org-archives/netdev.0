From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: remove unused original_flags
 struct slave member
Date: Wed, 02 Jun 2010 04:17:20 -0700 (PDT)
Message-ID: <20100602.041720.223465447.davem@davemloft.net>
References: <20100519111740.GB2788@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39685
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757844Ab0FBLRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 07:17:10 -0400
In-Reply-To: <20100519111740.GB2788@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 19 May 2010 13:17:41 +0200

> This is stored but never restored. So remove this as it is useless.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
