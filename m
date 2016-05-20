From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ps3_gelic: use kmemdup
Date: Fri, 20 May 2016 19:50:51 -0400 (EDT)
Message-ID: <20160520.195051.1439037257929657896.davem@davemloft.net>
References: <1463666090-16540-1-git-send-email-falakreyaz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
	christophe.jaillet@wanadoo.fr, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: falakreyaz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463666090-16540-1-git-send-email-falakreyaz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Date: Thu, 19 May 2016 19:24:41 +0530

> Use kmemdup when some other buffer is immediately copied into allocated
> region. It replaces call to allocation followed by memcpy, by a single
> call to kmemdup.
> 
> Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>

Applied.
