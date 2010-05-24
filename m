From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] enic: Use random mac addr when
 associating port-profile
Date: Sun, 23 May 2010 23:11:37 -0700 (PDT)
Message-ID: <20100523.231137.04685507.davem@davemloft.net>
References: <20100523032952.20200.30148.stgit@savbu-pc100.cisco.com>
	<20100523032957.20200.59700.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51802
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753799Ab0EXGL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:11:27 -0400
In-Reply-To: <20100523032957.20200.59700.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Sat, 22 May 2010 20:29:58 -0700

> From: Scott Feldman <scofeldm@cisco.com>
> 
> Use random mac addr for interface when associating port-profile to 
> dynamic enic device, in the case no mac addr was previous assigned.
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

Applied.
