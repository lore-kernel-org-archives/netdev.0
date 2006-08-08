From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [IPv4]: FIB configuration using struct fib_config
Date: Tue, 08 Aug 2006 16:12:24 -0700 (PDT)
Message-ID: <20060808.161224.78160715.davem@davemloft.net>
References: <20060808193822.104083150@postel.suug.ch>
	<20060808194600.996388029@postel.suug.ch>
	<20060808231102.GT14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:25321
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965063AbWHHXMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:12:18 -0400
To: tgraf@suug.ch
In-Reply-To: <20060808231102.GT14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 9 Aug 2006 01:11:03 +0200

> Hold on with this patch, netlink pid handling for netlink events
> is completely inconsistent. I want to figure out the right way
> to do it first.

Ok.
