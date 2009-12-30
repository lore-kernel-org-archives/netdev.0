From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/lib82596.c: use %pM to shown MAC address
Date: Wed, 30 Dec 2009 09:15:35 -0800 (PST)
Message-ID: <20091230.091535.71098062.davem@davemloft.net>
References: <BD79186B4FD85F4B8E60E381CAEE19090200F4C1@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752862AbZL3RPj@vger.kernel.org>
In-Reply-To: <BD79186B4FD85F4B8E60E381CAEE19090200F4C1@mi8nycmail19.Mi8.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Date: Mon, 28 Dec 2009 17:43:17 -0500

> Use the %pM kernel extension to display the MAC address.
> 
> The only difference in the output is that the MAC address is
> shown in the usual colon-separated hex notation instead of
> space-separated.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied.
