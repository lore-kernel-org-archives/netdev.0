From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH] net/ethernet/jme: disable ASPM
Date: Mon, 8 Oct 2012 20:33:16 +0100
Message-ID: <20121008193316.GA13684@srcf.ucam.org>
References: <1349722956-14159-1-git-send-email-kevin.baradon@gmail.com>
 <20121008.152426.1524908667081347879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kevin.baradon@gmail.com, cooldavid@cooldavid.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:60540 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab2JHTd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 15:33:26 -0400
Content-Disposition: inline
In-Reply-To: <20121008.152426.1524908667081347879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 08, 2012 at 03:24:26PM -0400, David Miller wrote:

> This should be a PCI quirk shouldn't it?

No, it's a driver-level policy decision.

-- 
Matthew Garrett | mjg59@srcf.ucam.org
