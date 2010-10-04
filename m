From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] [PATCH] qeth: tagging with VLAN-ID 0
Date: Sun, 03 Oct 2010 22:08:29 -0700 (PDT)
Message-ID: <20101003.220829.28819804.davem@davemloft.net>
References: <20101001125112.459999476@de.ibm.com>
	<20101001125142.037089467@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37769
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751738Ab0JDFII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 01:08:08 -0400
In-Reply-To: <20101001125142.037089467@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Fri, 01 Oct 2010 14:51:13 +0200

> From: Ursula Braun <ursula.braun@de.ibm.com>
> 
> This patch adapts qeth to handle tagged frames with VLAN-ID 0 and
> with or without priority information in the tag. It enables qeth to
> receive priority-tagged frames on a base interface, for example from
> z/OS, without configuring an additional VLAN interface.
> 
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

I'll apply this, thanks.
