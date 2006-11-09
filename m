From: David Miller <davem@davemloft.net>
Subject: Re: [patch] fix up generic csum_ipv6_magic function prototype
Date: Wed, 08 Nov 2006 23:55:48 -0800 (PST)
Message-ID: <20061108.235548.12921799.davem@davemloft.net>
References: <000301c703a3$0eedb340$ff0da8c0@amr.corp.intel.com>
	<20061108.230059.57444310.davem@davemloft.net>
	<20061109072216.GL29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kenneth.w.chen@intel.com, akpm@osdl.org, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21169
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1754362AbWKIHzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 02:55:42 -0500
To: viro@ftp.linux.org.uk
In-Reply-To: <20061109072216.GL29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>
Date: Thu, 9 Nov 2006 07:22:16 +0000

> I haven't touch that argument yet; if there's an agreement as to what should
> we switch to, I'll do that.  So... does everyone agree that u32 is the way
> to go?

I definitely do.
