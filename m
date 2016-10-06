From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] phy: micrel.c: Enable ksz9031 energy-detect
 power-down mode
Date: Wed, 05 Oct 2016 21:19:37 -0400 (EDT)
Message-ID: <20161005.211937.2062745471160637147.davem@davemloft.net>
References: <1475499870-11465-1-git-send-email-mike.looijmans@topic.nl>
        <1475560324-23346-1-git-send-email-mike.looijmans@topic.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        linux-kernel@vger.kernel.org
To: mike.looijmans@topic.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475560324-23346-1-git-send-email-mike.looijmans@topic.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Looijmans <mike.looijmans@topic.nl>
Date: Tue,  4 Oct 2016 07:52:04 +0200

> Set bit 0 in register 1C.23 to enable the EDPD feature of the
> KSZ9031 PHY. This reduces power consumption when the link is
> down.
> 
> Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>
> ---
> v2: Unconditionally enable EDPD mode

Applied.
