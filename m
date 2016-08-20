From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] PHY Kconfig and Makefile cleanup
Date: Fri, 19 Aug 2016 17:12:04 -0700 (PDT)
Message-ID: <20160819.171204.2140121457279123144.davem@davemloft.net>
References: <1471557366-21672-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55994 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754617AbcHTAMF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 20:12:05 -0400
In-Reply-To: <1471557366-21672-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 18 Aug 2016 23:56:04 +0200

> The Ethernet PHY directory has slowly been getting more entries.
> Split the entries in the Makefile and Kconfig into MDIO bus drivers
> and PHYs. Within these two groups, sort them. This should reduce merge
> conflicts and aid finding what one searches for.
> 
> The Kconfig text contains redundant "Driver for" and "Support for"
> which add little value, make the vendor less obvious, and defeat the
> shortcut key in the menu. Remove such text.

Series applied.
