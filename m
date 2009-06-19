From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ieee802154: use standard routine for printing dumps
Date: Fri, 19 Jun 2009 00:25:40 -0700 (PDT)
Message-ID: <20090619.002540.32287277.davem@davemloft.net>
References: <1245334607-16046-1-git-send-email-dbaryshkov@gmail.com>
	<1245334607-16046-2-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slapin@ossfans.org
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50169
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753194AbZFSHZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 03:25:36 -0400
In-Reply-To: <1245334607-16046-2-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Thu, 18 Jun 2009 18:16:46 +0400

> Use print_hex_dump_bytes instead of self-written dumping function
> for outputting packet dumps.
> 
> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>

Applied.
