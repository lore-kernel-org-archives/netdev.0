From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Replace "#include <asm/uaccess>" with "#include
 <linux/uaccess>"
Date: Sat, 21 Feb 2015 21:57:58 -0500 (EST)
Message-ID: <20150221.215758.744862583152640806.davem@davemloft.net>
References: <1424383087-8058-1-git-send-email-alex.slater.dev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: alex.slater.dev@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424383087-8058-1-git-send-email-alex.slater.dev@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex W Slater <alex.slater.dev@gmail.com>
Date: Thu, 19 Feb 2015 21:58:07 +0000

> Fix checkpatch.pl warning "Use #include <linux/uaccess.h> instead of <asm/uaccess.h>"
> 
> Signed-off-by: Alex W Slater <alex.slater.dev@gmail.com>

Applied to net-next.
