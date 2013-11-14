From: David Miller <davem@davemloft.net>
Subject: Re: Test program for SIOC{G,S}HWTSTAMP
Date: Thu, 14 Nov 2013 01:51:30 -0500 (EST)
Message-ID: <20131114.015130.1538290892331018410.davem@davemloft.net>
References: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
	<1384397184.29151.44.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab3KNGvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 01:51:32 -0500
In-Reply-To: <1384397184.29151.44.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 14 Nov 2013 02:46:24 +0000

> I used this to exercise the two ioctls.

You could put this under Documentation/networking/timestamping/

There is already example code there.
