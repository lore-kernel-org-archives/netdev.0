From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/13] [IPV6] Make IPV6_SUBTREES depend on
 IPV6_MULTIPLE_TABLES.
Date: Mon, 16 Oct 2006 22:13:00 -0700 (PDT)
Message-ID: <20061016.221300.106436814.davem@davemloft.net>
References: <45341F03.7050209@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3542
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423097AbWJQFNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 01:13:00 -0400
To: vnuorval@tcs.hut.fi
In-Reply-To: <45341F03.7050209@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Tue, 17 Oct 2006 03:08:35 +0300

> As IPV6_SUBTREES can't work without IPV6_MULTIPLE_TABLES have IPV6_SUBTREES
> depend on it.
> 
> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Good catch, patch applied, thanks.
