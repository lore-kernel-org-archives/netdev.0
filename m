From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net - IP_NODEFRAG option for IPv4 socket
Date: Wed, 23 Jun 2010 12:31:35 -0700 (PDT)
Message-ID: <20100623.123135.48523240.davem@davemloft.net>
References: <1276600052-16499-1-git-send-email-jolsa@redhat.com>
	<1276600052-16499-2-git-send-email-jolsa@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jengelh@medozas.de, kaber@trash.net,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-man@vger.kernel.org
To: jolsa@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60987
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753405Ab0FWTbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 15:31:23 -0400
In-Reply-To: <1276600052-16499-2-git-send-email-jolsa@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Olsa <jolsa@redhat.com>
Date: Tue, 15 Jun 2010 13:07:31 +0200

> this patch is implementing IP_NODEFRAG option for IPv4 socket.
> The reason is, there's no other way to send out the packet with user
> customized header of the reassembly part.
> 
> Signed-off-by: Jiri Olsa <jolsa@redhat.com>

Applied to net-next-2.6, thanks!
