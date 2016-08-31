From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: add MDB support
Date: Wed, 31 Aug 2016 14:15:57 -0700 (PDT)
Message-ID: <20160831.141557.1210437715859611830.davem@davemloft.net>
References: <20160831155005.2569-1-vivien.didelot@savoirfairelinux.com>
        <20160831160405.GA11775@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        f.fainelli@gmail.com
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831160405.GA11775@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 31 Aug 2016 18:04:05 +0200

> On Wed, Aug 31, 2016 at 11:50:02AM -0400, Vivien Didelot wrote:
>> This patchset adds the switchdev MDB object support to the DSA layer.
>> 
>> The MDB support for the mv88e6xxx driver is very similar to the FDB
>> support. The FDB operations care about unicast addresses while the MDB
>> operations care about multicast addresses.
>> 
>> Both operation set load/purge/dump the Address Translation Table (ATU),
>> thus common code is used.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Series applied, thanks everyone.
