From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [NETLINK]: Make use of NLA_STRING/NLA_NUL_STRING
 attribute validation
Date: Sat, 26 Aug 2006 20:13:29 -0700 (PDT)
Message-ID: <20060826.201329.26100423.davem@davemloft.net>
References: <20060822125354.196502354@postel.suug.ch>
	<20060822125840.588411880@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35238
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751189AbWH0DNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 23:13:41 -0400
To: tgraf@suug.ch
In-Reply-To: <20060822125840.588411880@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 22 Aug 2006 14:53:56 +0200

> Converts existing NLA_STRING attributes to use the new
> validation features, saving a couple of temporary buffers.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
