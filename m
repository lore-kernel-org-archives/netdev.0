From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6.26 patch 0/6][NETNS][IPV6] handling more proc per
 namespace
Date: Fri, 21 Mar 2008 04:16:37 -0700 (PDT)
Message-ID: <20080321.041637.236251538.davem@davemloft.net>
References: <20080313114609.176640638@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net, den@openvz.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36523
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753581AbYCULQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 07:16:20 -0400
In-Reply-To: <20080313114609.176640638@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 13 Mar 2008 12:46:09 +0100

> This patchset makes tcp6/udp6 to have their proc files to be per
> namespace. This is useful for netstat :)  
> It fixes also a compilation warning for multicast.

All applied and pushed to net-2.6.26, thanks!
