From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] macvlan: propogate mtu changes
Date: Wed, 29 Oct 2008 22:02:30 +0100
Message-ID: <4908CF66.3030802@trash.net>
References: <20081029125343.695eeb3c@extreme> <20081029125912.002dbe9d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43010 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283AbYJ2VCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 17:02:31 -0400
In-Reply-To: <20081029125912.002dbe9d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> If MTU of underlying real device is changed, propogate up to macvlan
> pseudo devices.

I'm going to do a similar patch for macvlan as I did for VLAN for
the MTU settings (desired MTU/operational MTU).

