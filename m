From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 8/11][IPV6] Use sysctl paths to register
 ipv6 sysctl tables
Date: Wed, 05 Dec 2007 01:44:18 -0800 (PST)
Message-ID: <20071205.014418.221313017.davem@davemloft.net>
References: <4755256F.9000505@openvz.org>
	<47552837.8080205@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38345
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750954AbXLEJoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:44:19 -0500
In-Reply-To: <47552837.8080205@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 04 Dec 2007 13:13:11 +0300

> I have already done this for core, ipv4 and tr tables, so
> repeat this for the ipv6 ones.
> 
> This makes the ipv6.ko smaller and creates the ground needed
> for net namespaces support in ipv6.ko ssctls.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
