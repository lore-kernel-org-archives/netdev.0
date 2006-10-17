From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/13] [IPV6] Always copy rt->u.dst.error when copying a
 rt6_info.
Date: Mon, 16 Oct 2006 22:15:36 -0700 (PDT)
Message-ID: <20061016.221536.09951577.davem@davemloft.net>
References: <45341F89.2040908@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44999
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423103AbWJQFPf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 01:15:35 -0400
To: vnuorval@tcs.hut.fi
In-Reply-To: <45341F89.2040908@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Tue, 17 Oct 2006 03:10:49 +0300

> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Looks good, applied.

Ville, can you fixup Thunderbird to not corrupt your patches?
The specific corruption is that if the patch has a completely
empty line with just a space at the beginning, thunderbird is
killing that space which makes the patch bad (at least in GIT's
eyes, which is all that matters :-)

Thanks!
