From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Document and use eeprom-length property
Date: Sat, 27 May 2017 18:42:34 -0400 (EDT)
Message-ID: <20170527.184234.1719294969155143427.davem@davemloft.net>
References: <1495755884-31341-1-git-send-email-andrew@lunn.ch>
        <20170526.150242.515745885812232154.davem@davemloft.net>
        <20170527081332.GB4528@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        vivien.didelot@savoirfairelinux.com
To: shawnguo@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52404 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdE0Wmj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 18:42:39 -0400
In-Reply-To: <20170527081332.GB4528@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawnguo@kernel.org>
Date: Sat, 27 May 2017 16:13:34 +0800

> On Fri, May 26, 2017 at 03:02:42PM -0400, David Miller wrote:
>> From: Andrew Lunn <andrew@lunn.ch>
>> Date: Fri, 26 May 2017 01:44:42 +0200
>> 
>> > The mv88e6xxx switch driver allows the size of the attached EEPROM to
>> > be described in DT. This property is missing from the binding
>> > documentation. Add it. And make use of it on the ZII Devel B board.
>> > 
>> > David, Shawn, please could you talk amongs yourself to decide who
>> > takes what.
>> 
>> I can take this if it works for Shawn, otherwise I'm also fine if Shawn
>> takes it and if so feel free to add my:
>> 
>> Acked-by: David S. Miller <davem@davemloft.net>
> 
> Hi David,
> 
> I see these two patches can be applied separately, so I picked up 2/2
> and left 1/2 to you.

Ok I applied 1/2, thanks.
