From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] bridge: add notification over netlink when STP
 changes state
Date: Wed, 18 May 2011 16:48:31 -0700
Message-ID: <20110518164831.333ef0a1@nehalam>
References: <20110518081718.0b1fc390@nehalam>
	<4DD3E38C.30609@candelatech.com>
	<20110518083948.261ded68@nehalam>
	<4DD3F168.1060308@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43611 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756276Ab1ERXse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2011 19:48:34 -0400
In-Reply-To: <4DD3F168.1060308@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I updated rstp daemon to handle hearing itself (and some other issues).
Not sure how many users there are of that code.

See:
  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/rstp.git

