From: David Miller <davem@davemloft.net>
Subject: Re: a maze of twisty stats, most different
Date: Thu, 28 Jun 2007 13:36:17 -0700 (PDT)
Message-ID: <20070628.133617.43010120.davem@davemloft.net>
References: <4683F10F.6070007@hp.com>
	<OF4B8149B6.D8E6CC86-ON88257308.006345F0-88257308.0064762A@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, csnook@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51050
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757619AbXF1Uf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 16:35:58 -0400
In-Reply-To: <OF4B8149B6.D8E6CC86-ON88257308.006345F0-88257308.0064762A@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Thu, 28 Jun 2007 11:17:51 -0700

> Comments?

I think sysfs is a better model for MIBs, the extensibility we
get for free since each SNMP MIB entry we want to add is simply
a new file.

I'd be quite thrilled to apply a patch which implemented this.
