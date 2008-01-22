From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/10][NETNS][FRAGS]: Move ctl tables around.
Date: Tue, 22 Jan 2008 06:00:54 -0800 (PST)
Message-ID: <20080122.060054.217836115.davem@davemloft.net>
References: <4795F524.8060204@openvz.org>
	<4795F5CB.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44975
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752086AbYAVOAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:00:46 -0500
In-Reply-To: <4795F5CB.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Jan 2008 16:55:23 +0300

> This is a preparation for sysctl netns-ization. 
> Move the ctl tables to the files, where the tuning
> variables reside. Plus make the helpers to register 
> the tables.
> 
> This will simplify the later patches and will keep
> similar things closer to each other.
> 
> ipv4, ipv6 and conntrack_reasm are patched differently,
> bu the result is all the tables are in appropriate files.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
