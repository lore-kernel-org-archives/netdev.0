From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 5/10][NETNS][FRAGS]: Duplicate sysctl tables
 for new namespaces.
Date: Tue, 22 Jan 2008 06:09:09 -0800 (PST)
Message-ID: <20080122.060909.260350832.davem@davemloft.net>
References: <4795F524.8060204@openvz.org>
	<4795F71E.40002@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753747AbYAVOJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:09:03 -0500
In-Reply-To: <4795F71E.40002@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Jan 2008 17:01:02 +0300

> Each namespace has to have own tables to tune their 
> different parameters, so duplicate the tables and 
> register them.
> 
> All the tables in sub-namespaces are temporarily made
> read-only.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

