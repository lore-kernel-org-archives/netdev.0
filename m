From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev/fec.c: add phylib supporting to enable carrier
 detection (v2)
Date: Thu, 01 Apr 2010 19:53:52 -0700 (PDT)
Message-ID: <20100401.195352.258678503.davem@davemloft.net>
References: <1270037444-8470-1-git-send-email-bryan.wu@canonical.com>
	<20100331122604.GV2241@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bryan.wu@canonical.com, gerg@uclinux.org,
	amit.kucheria@canonical.com, w.sang@pengutronix.de,
	kernel-team@lists.ubuntu.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: s.hauer@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100331122604.GV2241@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sascha Hauer <s.hauer@pengutronix.de>
Date: Wed, 31 Mar 2010 14:26:04 +0200

> On Wed, Mar 31, 2010 at 08:10:44PM +0800, Bryan Wu wrote:
>> BugLink: http://bugs.launchpad.net/bugs/457878
>> 
>> v2:
>>  - remove duplicated phy_speed caculation
>>  - fix the phy_speed caculation according to the DataSheet
>> 
>> v1:
>>  - removed old MII phy control code
>>  - add phylib supporting
>>  - add ethtool interface to make user space NetworkManager works
>> 
>> Tested on Freescale i.MX51 Babbage board.
>> 
>> This patch is based on a patch from Frederic Rodo <fred.rodo@gmail.com>
>> 
>> Cc: Frederic Rodo <fred.rodo@gmail.com>
>> Signed-off-by: Bryan Wu <bryan.wu@canonical.com>
> 
> Acked-by: Sascha Hauer <s.hauer@pengutronix.de>

Applied to net-next-2.6, thanks.
