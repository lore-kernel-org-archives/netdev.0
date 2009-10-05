From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] tehuti: Convert ethtool get_stats_count() ops to
 get_sset_count()
Date: Mon, 05 Oct 2009 00:13:39 -0700 (PDT)
Message-ID: <20091005.001339.159723654.davem@davemloft.net>
References: <1254432479.2735.24.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, baum@tehutinetworks.net, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41243
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758005AbZJEHNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:13:45 -0400
In-Reply-To: <1254432479.2735.24.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 01 Oct 2009 22:27:59 +0100

> This string query operation was supposed to be replaced by the
> generic get_sset_count() starting in 2007.  Convert tehuti's
> implementation.
> 
> Also remove the dummy self-test name which was not used since tehuti
> does not advertise any self-tests.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-next-2.6
