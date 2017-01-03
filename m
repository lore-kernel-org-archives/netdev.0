From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] igb: Fix hw_dbg logging in igb_update_flash_i210
Date: Tue, 03 Jan 2017 09:36:55 -0500 (EST)
Message-ID: <20170103.093655.1063644056873145777.davem@davemloft.net>
References: <14a3078ac22994d9c3dcd56c822555acfdb53b91.1483377891.git.peter.senna@collabora.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannu.lounento@ge.com, jeffrey.t.kirsher@intel.com,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: peter.senna@collabora.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14a3078ac22994d9c3dcd56c822555acfdb53b91.1483377891.git.peter.senna@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@collabora.com>
Date: Mon,  2 Jan 2017 18:26:06 +0100

> From: Hannu Lounento <hannu.lounento@ge.com>
> 
> Fix an if statement with hw_dbg lines where the logic was inverted with
> regards to the corresponding return value used in the if statement.
> 
> Signed-off-by: Hannu Lounento <hannu.lounento@ge.com>
> Signed-off-by: Peter Senna Tschudin <peter.senna@collabora.com>

I'm assuming I'll get this from the upstream Intel folks.
