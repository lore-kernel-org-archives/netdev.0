From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] uapi: fix linux/llc.h userspace compilation error
Date: Thu, 23 Feb 2017 10:47:14 -0500 (EST)
Message-ID: <20170223.104714.790588735202384939.davem@davemloft.net>
References: <20170222223826.GB14311@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170222223826.GB14311@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 23 Feb 2017 01:38:26 +0300

> Include <linux/if.h> to fix the following linux/llc.h userspace
> compilation error:
> 
> /usr/include/linux/llc.h:26:27: error: 'IFHWADDRLEN' undeclared here (not in a function)
>   unsigned char   sllc_mac[IFHWADDRLEN];
> 
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>

Applied.
