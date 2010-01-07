From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/firmware/iscsi_ibft.c: use %pM to show MAC
 address
Date: Thu, 07 Jan 2010 01:16:12 -0800 (PST)
Message-ID: <20100107.011612.17260804.davem@davemloft.net>
References: <201001050937.43896.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pjones@redhat.com
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932839Ab0AGJQT@vger.kernel.org>
In-Reply-To: <201001050937.43896.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Tue, 5 Jan 2010 09:37:43 -0700

> Use the %pM kernel extension to display the MAC address.
> 
> Also, remove the 'mac' variable and use nic->mac directly.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Acked-by: Peter Jones <pjones@redhat.com>

Applied.
