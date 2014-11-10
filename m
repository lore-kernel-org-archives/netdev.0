From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] 8139too: Allow setting MTU larger than 1500
Date: Mon, 10 Nov 2014 15:30:21 -0500 (EST)
Message-ID: <20141110.153021.292197986790796944.davem@davemloft.net>
References: <1415447316-12424-1-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bhelgaas@google.com, benoit.taine@lip6.fr, ebiederm@xmission.com
To: albeu@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415447316-12424-1-git-send-email-albeu@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Bedel <albeu@free.fr>
Date: Sat,  8 Nov 2014 12:48:35 +0100

> Replace the default ndo_change_mtu callback with one that allow
> setting MTU that the driver can handle.
> 
> Signed-off-by: Alban Bedel <albeu@free.fr>

Applied to net-next
