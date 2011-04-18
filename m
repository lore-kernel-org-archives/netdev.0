From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bna: fix for clean fw re-initialization
Date: Mon, 18 Apr 2011 12:28:17 -0700 (PDT)
Message-ID: <20110418.122817.15229388.davem@davemloft.net>
References: <1302804319-15677-1-git-send-email-rmody@brocade.com>
	<20110414.133957.226775217.davem@davemloft.net>
	<E5313AF6F2BFD14293E5FD0F94750F86A5D7348A7B@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@Brocade.COM
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57792
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753153Ab1DRT2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 15:28:51 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A5D7348A7B@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Mon, 18 Apr 2011 12:26:12 -0700

> We were not able to see these patches when we did a git-pull of 
> net-next-2.6. We were wondering if the patches are stuck behind
> others and not committed to the tree.

They went into net-2.6 since they are bug fixes and you didn't specify
which tree you wanted them to appear in.
