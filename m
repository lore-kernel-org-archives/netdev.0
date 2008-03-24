From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 3/5][UDP-Lite]: Clean up proc creation a bit.
Date: Mon, 24 Mar 2008 14:58:20 -0700 (PDT)
Message-ID: <20080324.145820.33167185.davem@davemloft.net>
References: <47E78776.4010207@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, dlezcano@fr.ibm.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36742
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754454AbYCXV63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 17:58:29 -0400
In-Reply-To: <47E78776.4010207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 24 Mar 2008 13:50:30 +0300

> Just introduce a helper to remove ifdefs from inside the
> udplite4_register function. This will help to make the next
> patch nicer.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
