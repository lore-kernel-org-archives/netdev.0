From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH 1/1] igb: Fix hw_dbg logging in igb_update_flash_i210
Date: Fri, 6 Jan 2017 03:44:24 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B820179EF@ORSMSX101.amr.corp.intel.com>
References: <14a3078ac22994d9c3dcd56c822555acfdb53b91.1483377891.git.peter.senna@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Hannu Lounento <hannu.lounento@ge.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "moderated list:INTEL ETHERNET DRIVERS"
        <intel-wired-lan@lists.osuosl.org>,
        "open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Peter Senna Tschudin <peter.senna@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14a3078ac22994d9c3dcd56c822555acfdb53b91.1483377891.git.peter.senna@collabora.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Peter Senna Tschudin
> Sent: Monday, January 2, 2017 9:26 AM
> Cc: Hannu Lounento <hannu.lounento@ge.com>; Peter Senna Tschudin
> <peter.senna@collabora.com>; Kirsher, Jeffrey T
> <jeffrey.t.kirsher@intel.com>; moderated list:INTEL ETHERNET DRIVERS
> <intel-wired-lan@lists.osuosl.org>; open list:NETWORKING DRIVERS
> <netdev@vger.kernel.org>; open list <linux-kernel@vger.kernel.org>
> Subject: [PATCH 1/1] igb: Fix hw_dbg logging in igb_update_flash_i210
> 
> From: Hannu Lounento <hannu.lounento@ge.com>
> 
> Fix an if statement with hw_dbg lines where the logic was inverted with
> regards to the corresponding return value used in the if statement.
> 
> Signed-off-by: Hannu Lounento <hannu.lounento@ge.com>
> Signed-off-by: Peter Senna Tschudin <peter.senna@collabora.com>
> ---
>  drivers/net/ethernet/intel/igb/e1000_i210.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
