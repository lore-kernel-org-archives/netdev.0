From: David Miller <davem@davemloft.net>
Subject: Re: iproute2: removing primary address removes secondaries
Date: Fri, 11 Jan 2008 17:59:07 -0800 (PST)
Message-ID: <20080111.175907.10105924.davem@davemloft.net>
References: <20080111163155.GA17637@piper.oerlikon.madduck.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: madduck@madduck.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46203
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762740AbYALB7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 20:59:07 -0500
In-Reply-To: <20080111163155.GA17637@piper.oerlikon.madduck.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


echo "1" >/proc/sys/net/ipv4/conf/all/promote_secondaries
