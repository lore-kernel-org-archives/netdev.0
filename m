From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] e1000e: Fix erroneous display of stats by
 ethtool -S
Date: Tue, 13 Oct 2009 12:10:39 -0700 (PDT)
Message-ID: <20091013.121039.176853758.davem@davemloft.net>
References: <20091013114454.GA2246@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
	emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40497
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761053AbZJMTKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 15:10:43 -0400
In-Reply-To: <20091013114454.GA2246@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Tue, 13 Oct 2009 17:15:09 +0530

> Commit fd8235bb overlooked the way offsets for netdev stats were considered.
> Because of this some of the stats shown by ethtool -S were wrong.
> This patch fixes it.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
