From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 2/5][NETNS][TCP]: Register /proc/net/tcp in
 a namespace.
Date: Mon, 24 Mar 2008 14:58:08 -0700 (PDT)
Message-ID: <20080324.145808.99384800.davem@davemloft.net>
References: <47E78716.7000903@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, dlezcano@fr.ibm.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753005AbYCXV6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 17:58:14 -0400
In-Reply-To: <47E78716.7000903@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 24 Mar 2008 13:48:54 +0300

> After the commit f40c8174d3c21bf178283f3ef3aa8c7bf238fdec ([NETNS][IPV4] 
> tcp - make proc handle the network namespaces) it is now possible to make
> this file present in newly created namespaces.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
