From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 6/10][NETNS][FRAGS]: Make the
 net.ipv4.ipfrag_timeout work in namespaces.
Date: Tue, 22 Jan 2008 06:09:47 -0800 (PST)
Message-ID: <20080122.060947.81130169.davem@davemloft.net>
References: <4795F524.8060204@openvz.org>
	<4795F769.3010103@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49794
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751587AbYAVOJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:09:40 -0500
In-Reply-To: <4795F769.3010103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Jan 2008 17:02:17 +0300

> Move it to the netns_frags, adjust the usage and
> make the appropriate ctl table writable.
> 
> Now fragment, that live in different namespaces can
> live for different times.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
