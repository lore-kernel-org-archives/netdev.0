From: Patrick McHardy <kaber@trash.net>
Subject: Re: sky bugs in 2.6.22-rc5
Date: Mon, 18 Jun 2007 22:13:50 +0200
Message-ID: <4676E77E.4080707@trash.net>
References: <4676E1DD.1060007@trash.net> <20070618130414.35801913@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41584 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764830AbXFRUNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 16:13:52 -0400
In-Reply-To: <20070618130414.35801913@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Does this fix it?  It was possible for the PHY interrupt to race
> while bringing link up.


No, both problems are still present.
