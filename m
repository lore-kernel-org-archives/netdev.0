From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 1/5][NETNS][UDP]: Register /proc/net/udp in
 a namespace.
Date: Mon, 24 Mar 2008 14:58:00 -0700 (PDT)
Message-ID: <20080324.145800.122173233.davem@davemloft.net>
References: <47E786A2.6090505@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, dlezcano@fr.ibm.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36732
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751596AbYCXV6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 17:58:06 -0400
In-Reply-To: <47E786A2.6090505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 24 Mar 2008 13:46:58 +0300

> After the commit a91275eff43a527e1a25d6d034cbcd19ee323e64 ([NETNS][IPV6]
> udp - make proc handle the network namespace) it is now possible to make
> this file present in newly created namespaces.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
