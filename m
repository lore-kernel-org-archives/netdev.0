From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Implement ndo_gso_check()
Date: Tue, 09 Dec 2014 16:05:45 -0500 (EST)
Message-ID: <20141209.160545.1119651138018658437.davem@davemloft.net>
References: <1417808146-3436-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariel.elior@qlogic.com, jesse@nicira.com,
	therbert@google.com, linux-kernel@vger.kernel.org
To: joestringer@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417808146-3436-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joestringer@nicira.com>
Date: Fri,  5 Dec 2014 11:35:46 -0800

> Use vxlan_gso_check() to advertise offload support for this NIC.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Applied, thanks.
