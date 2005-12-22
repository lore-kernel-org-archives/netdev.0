From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] VLAN: Add two missing checks to vlan_ioctl_handler()
Date: Wed, 21 Dec 2005 18:39:59 -0800 (PST)
Message-ID: <20051221.183959.77486794.davem@davemloft.net>
References: <20051221205015.GC24213@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vlan@candelatech.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965038AbVLVCj5@vger.kernel.org>
To: mikukkon@iki.fi
In-Reply-To: <20051221205015.GC24213@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mika Kukkonen <mikukkon@iki.fi>
Date: Wed, 21 Dec 2005 22:50:15 +0200

> In vlan_ioctl_handler() the code misses couple checks for
> error return values.
> 
> Signed-of-by: Mika Kukkonen <mikukkon@iki.fi>

Looks good, applied, thanks.
