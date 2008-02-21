From: Olof Johansson <olof@lixom.net>
Subject: [patch 0/6] pasemi_mac updates for 2.6.26
Date: Wed, 20 Feb 2008 20:57:53 -0600
Message-ID: <20080221025753.903665000@lixom.net>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	pasemi-linux@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:44443 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355AbYBUDPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 22:15:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a set of updates for pasemi_mac for 2.6.26. Some of them touch
the dma_lib in the platform code as well, but it's easier if it's all
merged through netdev to avoid dependencies.

Major highlights are jumbo frame support and ethtool basics, the rest
is mostly minor plumbing around it.

-- 

