From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan: dscc4: fix build warning Wunused-but-set-variable
Date: Sun, 07 Jun 2015 00:16:28 -0700 (PDT)
Message-ID: <20150607.001628.2135737400226810600.davem@davemloft.net>
References: <1433580077-1271-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433580077-1271-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Sat,  6 Jun 2015 10:41:17 +0200

> Fix:
> drivers/net/wan/dscc4.c: In function 'dscc4_open':
> drivers/net/wan/dscc4.c:1049:25: warning: variable 'ppriv' set but not used
> [-Wunused-but-set-variable]
> 
> This has been in there unused since 1da177e4c3f (Linux-2.6.12-rc2) simply
> remove it.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Applied, thanks.
