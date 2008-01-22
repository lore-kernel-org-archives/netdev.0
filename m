From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 7/10][NETNS][FRAGS]: Make thresholds work in
 namespaces.
Date: Tue, 22 Jan 2008 06:10:25 -0800 (PST)
Message-ID: <20080122.061025.133778020.davem@davemloft.net>
References: <4795F524.8060204@openvz.org>
	<4795F83B.9040005@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49797
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753870AbYAVOKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:10:18 -0500
In-Reply-To: <4795F83B.9040005@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Jan 2008 17:05:47 +0300

> This is the same as with the timeout variable.
> 
> Currently, after exceeding the high threshold _all_
> the fragments are evicted, but it will be fixed in 
> later patch.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
