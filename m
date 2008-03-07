From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make /proc/net a symlink on /proc/self/net (v3)
Date: Fri, 07 Mar 2008 11:09:22 -0800 (PST)
Message-ID: <20080307.110922.16187211.davem@davemloft.net>
References: <47D1462F.5060800@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, ebiederm@xmission.com,
	sds@tycho.nsa.gov, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37978
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755605AbYCGTJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 14:09:22 -0500
In-Reply-To: <47D1462F.5060800@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 07 Mar 2008 16:42:07 +0300

> Current /proc/net is done with so called "shadows", but current
> implementation is broken and has little chances to get fixed.
 ...

Applied, thanks Pavel.

I'm travelling so it might take a day or two for me to get this
to Linus.
