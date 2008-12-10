From: David Miller <davem@davemloft.net>
Subject: Re: [patch 6/7] bonding: make tbl argument to bond_parse_parm()
 const
Date: Tue, 09 Dec 2008 23:10:23 -0800 (PST)
Message-ID: <20081209.231023.182068017.davem@davemloft.net>
References: <20081209200750.490739902@eitzenberger.org>
	<20081209201451.115627905@eitzenberger.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754567AbYLJHKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 02:10:22 -0500
In-Reply-To: <20081209201451.115627905@eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: holger@eitzenberger.org
Date: Tue, 09 Dec 2008 21:07:56 +0100

> bond_parse_parm() parses a parameter table for a particular value and
> is therefore not modifying the table at all.  Therefore make the 2nd
> argument const, thus allowing to make the tables const later.
> 
> Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Applied.
