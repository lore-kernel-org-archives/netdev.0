From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2008-04-15
Date: Tue, 15 Apr 2008 19:20:42 -0700 (PDT)
Message-ID: <20080415.192042.119702071.davem@davemloft.net>
References: <20080415193857.GA16625@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760410AbYDPCUy@vger.kernel.org>
In-Reply-To: <20080415193857.GA16625@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 15 Apr 2008 15:38:57 -0400

> This set looks bigger than it really is...three of the patches deal
> with a subtle API change for the SSB bus to do DMA correctly on
> architectures with complex DMA requirements.  The changes in those
> patches amount to applying the same one-line change in dozens of
> places across three drivers (b44, b43, and b43legacy).
> 
> Also included are a number of MAINTAINERS updates.  I guess everyone
> forgets about these until the release nears.
> 
> Finally there are a few minor fixes, like the rfkill fix to only toggle
> state for the correct device type rather than all devices on a system,
> the rtl8187 priv->vif fix, the gelic IE overrun fix, and the mac80211
> fix to limit log SPAM.
> 
> Please let me know if there are problems!  Hopefully this will be the
> last round before 2.6.25...(famous last words...)

Pulled, thanks John.
