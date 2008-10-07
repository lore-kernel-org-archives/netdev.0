From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: add mc_count to in_device.
Date: Tue, 07 Oct 2008 15:35:15 -0700 (PDT)
Message-ID: <20081007.153515.188169370.davem@davemloft.net>
References: <b25312890810010004p15e85df1u69125c7fa47ae01f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, pekkas@netcore.fi
To: roszenrami@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53084
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755591AbYJGWfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 18:35:40 -0400
In-Reply-To: <b25312890810010004p15e85df1u69125c7fa47ae01f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <roszenrami@gmail.com>
Date: Wed, 1 Oct 2008 10:04:48 +0300

> This patch add mc_count to struct in_device and
> updates increment/decrement/initilaize of this field in IPv4 and in IPv6.
> 
> - Also printing the vfs /proc entry (/proc/net/igmp) is adjusted to
> use the new mc_count.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.
