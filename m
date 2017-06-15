From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] net: dsa: prefix Global macros
Date: Thu, 15 Jun 2017 14:08:18 -0400 (EDT)
Message-ID: <20170615.140818.414700278549922831.davem@davemloft.net>
References: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
        <20170615170311.GF3786@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        f.fainelli@gmail.com
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615170311.GF3786@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 15 Jun 2017 19:03:11 +0200

> On Thu, Jun 15, 2017 at 12:13:58PM -0400, Vivien Didelot wrote:
>> This patch series is the 2/3 step of the register definitions cleanup.
>> It brings no functional changes.
>> 
>> It prefixes and documents all Global (1) registers with MV88E6XXX_G1_
>> (or a specific model like MV88E6352_G1_STS_PPU_STATE), and prefers a
>> 16-bit hexadecimal representation of the Marvell registers layout.
>> 
>> The next and last patchset will prefix the Global 2 registers.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Series applied, thanks everyone.
