From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Add a veth_get_peer() and veth_set_peer() functions
Date: Thu, 21 Jan 2010 01:24:39 -0800 (PST)
Message-ID: <20100121.012439.82033759.davem@davemloft.net>
References: <1263999673-11279-1-git-send-email-danms@us.ibm.com>
	<1263999673-11279-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, orenl@librato.com,
	netdev@vger.kernel.org
To: danms@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52659
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753088Ab0AUJY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 04:24:28 -0500
In-Reply-To: <1263999673-11279-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If you're going to CC: netdev on your first two patches
that expose infrastructure, you should CC: us on the
third patch too so we can see how in the world you're
using this stuff.
