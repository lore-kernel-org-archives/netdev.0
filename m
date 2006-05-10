From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/2] register_netdevice and sysfs changes
Date: Wed, 10 May 2006 13:19:35 -0700 (PDT)
Message-ID: <20060510.131935.107763128.davem@davemloft.net>
References: <20060510171452.619146000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:29831
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932076AbWEJUUM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 16:20:12 -0400
To: shemminger@osdl.org
In-Reply-To: <20060510171452.619146000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 10 May 2006 10:14:52 -0700

> This is a signed-off version of yesterday's fix, plus the bridge
> code no longer needs to be so tricky.

I'll apply this stuff, thanks a lot.

Although since I have the blocking --> raw notifier fixup in
my tree I'll need to fixup the rejects in the net/core/dev.c
part of the first patch.

Thanks.
