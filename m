From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] be2net: fix bug in vlan rx path for big endian
 architecture
Date: Thu, 01 Apr 2010 17:26:27 -0700 (PDT)
Message-ID: <20100401.172627.04452144.davem@davemloft.net>
References: <20100331120021.GA9185@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60831
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756305Ab0DBA00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 20:26:26 -0400
In-Reply-To: <20100331120021.GA9185@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Wed, 31 Mar 2010 17:30:32 +0530

> vlan traffic on big endian architecture is broken.
> Need to swap the vid before giving packet to stack.
> This patch fixes it.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied
