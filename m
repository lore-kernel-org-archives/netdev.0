From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net-bonding: Adding support for throughputs larger
 than 65536 Mbps
Date: Thu, 14 Apr 2011 22:04:11 -0700 (PDT)
Message-ID: <20110414.220411.183045866.davem@davemloft.net>
References: <1302744151-12452-1-git-send-email-decot@google.com>
	<1302744151-12452-3-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: decot@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302744151-12452-3-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@google.com>
Date: Wed, 13 Apr 2011 18:22:31 -0700

> This updates the bonding driver to support v2.6.27-rc3 enhancements
> (b11f8d8c aka. "ethtool: Expand ethtool_cmd.speed to 32 bits") which
> allow to encode the Mbps link speed on 32-bits (Max 4 Pbps) instead of
> 16 (Max 65536 Mbps).
> 
> This patch also attempts to compact struct slave by reordering its
> fields.
> 
> Signed-off-by: David Decotigny <decot@google.com>

Applied.
