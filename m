From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/11] net/rds: use prink_ratelimited() instead of
 printk_ratelimit()
Date: Fri, 17 Jun 2011 00:03:28 -0400 (EDT)
Message-ID: <20110617.000328.159880820812256016.davem@davemloft.net>
References: <cover.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
	<639d68afea7b4b37a5b8b228f3b15f4f81a61ed8.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	christian.dietrich@informatik.uni-erlangen.de
To: manuel.f.zerpies@ww.stud.uni-erlangen.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <639d68afea7b4b37a5b8b228f3b15f4f81a61ed8.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Manuel Zerpies <manuel.f.zerpies@ww.stud.uni-erlangen.de>
Date: Thu, 16 Jun 2011 14:09:57 +0200

> Since printk_ratelimit() shouldn't be used anymore (see comment in
> include/linux/printk.h), replace it with printk_ratelimited()
> 
> Signed-off-by: Manuel Zerpies <manuel.f.zerpies@ww.stud.uni-erlangen.de>

Applied.
