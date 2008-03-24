From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 4/5][NETNS][UDP-Lite]: Register
 /proc/net/udplite(6) in a namespace.
Date: Mon, 24 Mar 2008 14:58:26 -0700 (PDT)
Message-ID: <20080324.145826.114363838.davem@davemloft.net>
References: <47E7880D.8000501@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, dlezcano@fr.ibm.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751869AbYCXV6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 17:58:34 -0400
In-Reply-To: <47E7880D.8000501@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 24 Mar 2008 13:53:01 +0300

> UDP-Lite sockets are displayed in another files, rather than
> UDP ones, so make the present in namespaces as well.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
