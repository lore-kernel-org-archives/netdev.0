From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethernet: sc92031 is not Realtek
Date: Tue, 01 Nov 2011 19:33:18 -0400 (EDT)
Message-ID: <20111101.193318.633990180703042035.davem@davemloft.net>
References: <1319581944-2707-1-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, nic_swsd@realtek.com,
	romieu@fr.zoreil.com, jgarzik@pobox.com, becker@scyld.com
To: cesarb@cesarb.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319581944-2707-1-git-send-email-cesarb@cesarb.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cesar Eduardo Barros <cesarb@cesarb.net>
Date: Tue, 25 Oct 2011 20:32:24 -0200

> While the SC92031 could be found on fake "Realtek" NICs, it has no
> relationship to Realtek, and is actually from Silan.
> 
> Create a new subdirectory for silan and move sc92031 there.
> 
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>

Applied.
