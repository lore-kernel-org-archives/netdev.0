From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/3][NETNS][IPV6] make anycast and ip6_flowlabels per
 namespace
Date: Wed, 26 Mar 2008 17:01:05 -0700 (PDT)
Message-ID: <20080326.170105.89441893.davem@davemloft.net>
References: <20080326122832.564021438@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, den@openvz.org,
	xemul@openvz.org, benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36103
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753960AbYC0ABI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 20:01:08 -0400
In-Reply-To: <20080326122832.564021438@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Wed, 26 Mar 2008 13:28:32 +0100

> This patch makes the anycast and ip6_flowlabel per namespace.

Applied and pushed out to net-2.6.26, thanks!
