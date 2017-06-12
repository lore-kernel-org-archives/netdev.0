From: Rohit Vaswani <rvaswani@nvidia.com>
Subject: Bluetooth: might sleep error in hidp_session_thread
Date: Mon, 12 Jun 2017 18:31:36 +0000
Message-ID: <7be134d7f9904082a35a9cc926ec24d3@HQMAIL106.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>,
        Johan Hedberg <johan.hedberg@intel.com>,
        "Peter Hurley" <peter@hurleysoftware.com>,
        Jeffy Chen <jeffy.chen@rock-chips.com>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>
To: Jeffy Chen <jeffy.chen@rock-chips.com>,
        "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeffy,

I was looking into the patch from Jeffy Chen from February 14 2017  : 
 [v4,3/3] Bluetooth: hidp: fix possible might sleep error in hidp_session_thread: https://patchwork.kernel.org/patch/9570931/

We faced a similar issue and this patch seems to fix the problem in our preliminary test.
I am trying to check if there was a reason this wasn't merged earlier ?

Thanks,
Rohit

nvpublic
