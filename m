From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] : Fix pointer copy size for encap_tmpl and
 coaddr.
Date: Fri, 24 Aug 2007 23:30:17 -0700 (PDT)
Message-ID: <20070824.233017.16508113.davem@davemloft.net>
References: <20070822145632.087638328@lsx.localdomain>
	<11879499202750-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45127
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759069AbXHYGan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:30:43 -0400
In-Reply-To: <11879499202750-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri, 24 Aug 2007 19:05:20 +0900

> This is minor fix about sizeof argument using with kmemdup().
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Patch applied, thank you!
