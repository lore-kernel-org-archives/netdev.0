From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30 1/2] cxgb3 - Notify fatal errors
Date: Mon, 26 Jan 2009 22:22:32 -0800 (PST)
Message-ID: <20090126.222232.232005024.davem@davemloft.net>
References: <20090126174605.29703.40342.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	wenxiong@us.ibm.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751225AbZA0GWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 01:22:34 -0500
In-Reply-To: <20090126174605.29703.40342.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 26 Jan 2009 09:46:05 -0800

> Set up a notification mechanism to inform upper layer modules
> (iWARP, iSCSI) of a chip reset due to an EEH event or a fatal error.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
