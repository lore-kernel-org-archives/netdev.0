From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: phy: Create sysfs reciprocal
 links for attached_dev/phydev
Date: Fri, 26 May 2017 14:38:05 -0400 (EDT)
Message-ID: <20170526.143805.2154551237033360040.davem@davemloft.net>
References: <20170525162143.18319-1-f.fainelli@gmail.com>
        <20170525164227.GB18357@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43356 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932235AbdEZSiH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 14:38:07 -0400
In-Reply-To: <20170525164227.GB18357@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 25 May 2017 18:42:27 +0200

> On Thu, May 25, 2017 at 09:21:40AM -0700, Florian Fainelli wrote:
>> Hi David, Andrew,
>> 
>> This patch series addresses a device topology shortcoming where a program
>> scanning /sys would not be able to establish a mapping between the network
>> device and the PHY device.
>> 
>> In the process it turned out that no PHY device documentation existed for
>> sysfs attributes.
>> 
>> Thanks!
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Series applied, thanks everyone.
