From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] macvlan: add support for ethtool get settings
Date: Wed, 29 Oct 2008 22:01:28 +0100
Message-ID: <4908CF28.4060704@trash.net>
References: <20081029125343.695eeb3c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42989 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbYJ2VBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 17:01:31 -0400
In-Reply-To: <20081029125343.695eeb3c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> If macvlan's are used, it is useful to propgate speed and other settings
> from underlying device up for application usage.
>   

Acked-by: Patrick McHardy <kaber@trash.net>
