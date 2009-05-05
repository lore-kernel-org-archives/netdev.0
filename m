From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: get rid of CONFIG_PROC_FS ifdefs
Date: Tue, 05 May 2009 12:27:25 -0700 (PDT)
Message-ID: <20090505.122725.200630297.davem@davemloft.net>
References: <20090505162051.GG3552@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47584
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755535AbZEET1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 15:27:30 -0400
In-Reply-To: <20090505162051.GG3552@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 5 May 2009 18:20:51 +0200

> Remove CONFIG_PROC_FS ifdefs from the code by adding void functions.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied to net-next-2.6
