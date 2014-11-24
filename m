From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139too: The maximum MTU should allow for VLAN headers
Date: Mon, 24 Nov 2014 15:27:40 -0500 (EST)
Message-ID: <20141124.152740.1226649067585496281.davem@davemloft.net>
References: <1416744476-7372-1-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk, ebiederm@xmission.com,
	bhelgaas@google.com, benoit.taine@lip6.fr,
	linux-kernel@vger.kernel.org
To: albeu@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416744476-7372-1-git-send-email-albeu@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Bedel <albeu@free.fr>
Date: Sun, 23 Nov 2014 13:07:54 +0100

> As pointed out by Ben Hutchings drivers that allow using VLAN have to
> provide enough headroom for the VLAN tags.
> 
> Signed-off-by: Alban Bedel <albeu@free.fr>

Applied to net-next, but I shouldn't have to guess around about what
tree your patch is for.

In the future you must specify explicitly what tree your patch is
targetted at by saying either "[PATCH net] " or "[PATCH net-next] "
in your subject line.

Thanks.
