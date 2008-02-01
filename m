From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan tag match
Date: Fri, 01 Feb 2008 06:34:34 +0100
Message-ID: <47A2AF6A.1060200@trash.net>
References: <20080131.194644.03127203.davem@davemloft.net> <20080131210732.25f42884@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37206 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbYBAFep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 00:34:45 -0500
In-Reply-To: <20080131210732.25f42884@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Provide a way to use tc filters on vlan tag even if tag is buried in
> skb due to hardware acceleration.

Looks reasonable. Would you like to add the same feature to the
flow classifier?

