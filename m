From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/5] qeth: fix usage of netdev_ops
Date: Fri, 09 Jan 2009 23:08:59 -0800 (PST)
Message-ID: <20090109.230859.142542577.davem@davemloft.net>
References: <20090109134355.784732000@de.ibm.com>
	<20090109134443.557577000@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56630
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753437AbZAJHI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:08:58 -0500
In-Reply-To: <20090109134443.557577000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Fri, 09 Jan 2009 14:44:00 +0100

> From: Frank Blaschka <frank.blaschka@de.ibm.com>
> 
> Have separate netdev_ops for OSA and HiperSocket/TR. 
> 
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Applied.
