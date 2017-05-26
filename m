From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Document and use eeprom-length property
Date: Fri, 26 May 2017 15:02:42 -0400 (EDT)
Message-ID: <20170526.150242.515745885812232154.davem@davemloft.net>
References: <1495755884-31341-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawnguo@kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43668 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbdEZTCo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 15:02:44 -0400
In-Reply-To: <1495755884-31341-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 26 May 2017 01:44:42 +0200

> The mv88e6xxx switch driver allows the size of the attached EEPROM to
> be described in DT. This property is missing from the binding
> documentation. Add it. And make use of it on the ZII Devel B board.
> 
> David, Shawn, please could you talk amongs yourself to decide who
> takes what.

I can take this if it works for Shawn, otherwise I'm also fine if Shawn
takes it and if so feel free to add my:

Acked-by: David S. Miller <davem@davemloft.net>
