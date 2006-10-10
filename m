From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/02 V3] net/ipv6: seperate sit driver to extra module
Date: Tue, 10 Oct 2006 14:47:53 -0700 (PDT)
Message-ID: <20061010.144753.57160083.davem@davemloft.net>
References: <20061010153745.GA27455@zlug.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030507AbWJJVsE@vger.kernel.org>
To: joro-lkml@zlug.org
In-Reply-To: <20061010153745.GA27455@zlug.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joerg Roedel <joro-lkml@zlug.org>
Date: Tue, 10 Oct 2006 17:37:45 +0200

> This patch removes the driver of the IPv6-in-IPv4 tunnel driver (sit)
> from the IPv6 module. It adds an option to Kconfig which makes it
> possible to compile it as a seperate module.
> 
> Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>

Applied, thanks.
