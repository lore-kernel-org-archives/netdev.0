From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET] Begin of transformations to new netlink api
Date: Fri, 04 Aug 2006 23:21:03 -0700 (PDT)
Message-ID: <20060804.232103.21906202.davem@davemloft.net>
References: <20060805003452.493542515@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41867
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161488AbWHEGUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 02:20:55 -0400
To: tgraf@suug.ch
In-Reply-To: <20060805003452.493542515@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sat, 05 Aug 2006 02:34:52 +0200

> First batch of patches converting existing netlink code to use
> the new api. Fixing lots of unvalidated accesses to attributes.

Looks very nice, all applied to net-2.6.19, thanks Thomas.

I've also rebased the net-2.6.19 GIT tree.
