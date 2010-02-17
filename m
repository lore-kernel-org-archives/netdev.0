From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ll_temac: Fix MAC address configuration from userland
Date: Wed, 17 Feb 2010 13:42:41 -0800 (PST)
Message-ID: <20100217.134241.12902816.davem@davemloft.net>
References: <1266429307-11765-1-git-send-email-steve@digidescorp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: steve@digidescorp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1266429307-11765-1-git-send-email-steve@digidescorp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Steven J. Magnani" <steve@digidescorp.com>
Date: Wed, 17 Feb 2010 11:55:07 -0600

> A userland command to set the LLTEMAC MAC address,
> i.e. "ifconfig eth0 hw addr xx:yy:zz:pp:dd:qq",
> results in a device address of 00:01:xx:yy:zz:pp.
> Correct this.
> 
> Signed-off-by: Steven J. Magnani <steve@digidescorp.com>

Applied.
