From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-2.6.26] [NETNS]: Compilation warnings under
 CONFIG_NET_NS.
Date: Wed, 26 Mar 2008 00:48:40 -0700 (PDT)
Message-ID: <20080326.004840.24485682.davem@davemloft.net>
References: <1206517259-29152-1-git-send-email-den@openvz.org>
	<1206517259-29152-2-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org,
	yoshfuji@linux-ipv6.org, dlezcano@fr.ibm.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52107
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752412AbYCZHsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 03:48:41 -0400
In-Reply-To: <1206517259-29152-2-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 26 Mar 2008 10:40:59 +0300

> Recent commits from YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> have been introduced a several compilation warnings
> 'assignment discards qualifiers from pointer target type'
> due to extra const modifier in the inline call parameters of
> {dev|sock|twsk}_net_set.
> 
> Drop it.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Also applied, thanks a lot.
