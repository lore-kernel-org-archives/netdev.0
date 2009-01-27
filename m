From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30 2/2] iw_cxgb3 - handle chip reset notifications
Date: Mon, 26 Jan 2009 22:22:37 -0800 (PST)
Message-ID: <20090126.222237.129375210.davem@davemloft.net>
References: <20090126174611.29736.55008.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	wenxiong@us.ibm.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53592
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752365AbZA0GWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 01:22:40 -0500
In-Reply-To: <20090126174611.29736.55008.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 26 Jan 2009 09:46:11 -0800

> Freeze activity when notified that the underlying chip
> is getting reset on a EEH event or fatal error.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
