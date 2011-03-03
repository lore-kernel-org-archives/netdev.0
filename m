From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2 1/2] dcbnl: add support for retrieving
 peer configuration - ieee
Date: Wed, 02 Mar 2011 21:59:04 -0800 (PST)
Message-ID: <20110302.215904.115943187.davem@davemloft.net>
References: <1298819071.4544.9.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, eilong@broadcom.com,
	netdev@vger.kernel.org
To: shmulikr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37076
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753960Ab1CCF61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 00:58:27 -0500
In-Reply-To: <1298819071.4544.9.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Shmulik Ravid" <shmulikr@broadcom.com>
Date: Sun, 27 Feb 2011 17:04:31 +0200

> These 2 patches add the support for retrieving the remote or peer DCBX
> configuration via dcbnl for embedded DCBX stacks. The peer configuration
> is part of the DCBX MIB and is useful for debugging and diagnostics of
> the overall DCB configuration. The first patch add this support for IEEE
> 802.1Qaz standard the second patch add the same support for the older
> CEE standard. Diff for v2 - the peer-app-info is CEE specific.
> 
> 
> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>

Applied.
