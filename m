From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 0/7] Refactor macvtap to re-use tap functionality by
 other virtual intefaces
Date: Wed, 25 Jan 2017 23:06:59 -0500 (EST)
Message-ID: <20170125.230659.1003672790271737098.davem@davemloft.net>
References: <1485379539-32932-1-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org
To: sainath.grandhi@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485379539-32932-1-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sainath Grandhi <sainath.grandhi@intel.com>
Date: Wed, 25 Jan 2017 13:25:32 -0800

> Tap character devices can be implemented on other virtual interfaces like
> ipvlan, similar to macvtap. Source code for tap functionality in macvtap
> can be re-used for this purpose.
> 
> This patch series splits macvtap source into two modules, macvtap and tap.
> This patch series also includes a patch for implementing tap character
> device driver based on the IP-VLAN network interface, called ipvtap.
> 
> These patches are tested on x86 platform.

Please resubmit this series, after you have waited for other feedback,
with your Subject lines fixed.

Subsystem prefixes in the Subject lines such as "TAP" and "IPVTAP"
should be in all lowercase letters not all uppercase.
