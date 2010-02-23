From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: better document max_addresses parameter
Date: Tue, 23 Feb 2010 01:25:33 -0800 (PST)
Message-ID: <20100223.012533.00483943.davem@davemloft.net>
References: <bug-15342-10286@http.bugzilla.kernel.org/>
	<20100222130858.3c186888.akpm@linux-foundation.org>
	<4B8304C9.1030800@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nedyalkor@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56512
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751654Ab0BWJZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 04:25:15 -0500
In-Reply-To: <4B8304C9.1030800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Mon, 22 Feb 2010 17:27:21 -0500

> Andrew Morton wrote:
>>> >From ip-sysctl.txt file in kernel documentation I can see following description
>>> for max_addresses:
>>> max_addresses - INTEGER
>>>         Number of maximum addresses per interface.  0 disables limitation.
>>>         It is recommended not set too large value (or 0) because it would
>>>         be too easy way to crash kernel to allow to create too much of
>>>         autoconfigured addresses.
>            ^^^^^^^^^^^^^^
> 
>>> If this parameter applies only for auto-configured IP addressed, please state
>>> it more clearly in docs or rename the parameter to show that it refers to
>>> auto-configuration.
> 
> It did mention autoconfigured in the text, but the below makes it more obvious.
> 
> 
> More clearly document IPv6 max_addresses parameter.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied.
