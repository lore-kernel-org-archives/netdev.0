From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xilinx: emaclite: Fallback to random MAC address.
Date: Sat, 20 Aug 2016 22:25:23 -0700 (PDT)
Message-ID: <20160820.222523.1129533786670584939.davem@davemloft.net>
References: <1471608721-26984-1-git-send-email-daro@hms.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mago@hms.se,
        daro@hms.se
To: danielromell@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471608721-26984-1-git-send-email-daro@hms.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Romell <danielromell@gmail.com>
Date: Fri, 19 Aug 2016 14:12:01 +0200

> If the address configured in the device tree is invalid, the
> driver will fallback to using a random address from the locally
> administered range.
> 
> Signed-off-by: Daniel Romell <daro@hms.se>

Applied.
