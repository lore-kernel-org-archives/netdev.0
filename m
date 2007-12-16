From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/7] Add the netns_ipv4 struct
Date: Sun, 16 Dec 2007 13:29:43 -0800 (PST)
Message-ID: <20071216.132943.212109801.davem@davemloft.net>
References: <475ECC69.1040809@openvz.org>
	<475ECCD6.4080205@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37959
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758161AbXLPV35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 16:29:57 -0500
In-Reply-To: <475ECCD6.4080205@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 11 Dec 2007 20:45:58 +0300

> The ipv4 will store its parameters inside this structure.
> This one is empty now, but it will be eventually filled.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
