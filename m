From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/mlx5e: Use device ID defines
Date: Thu, 22 Jun 2017 11:04:35 -0400 (EDT)
Message-ID: <20170622.110435.1749883933517811245.davem@davemloft.net>
References: <20170620172126.784.3849.stgit@amt.stowe>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, noaos@mellanox.com, saeedm@mellanox.com,
        linux-kernel@vger.kernel.org, tariqt@mellanox.com
To: myron.stowe@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620172126.784.3849.stgit@amt.stowe>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Myron Stowe <myron.stowe@redhat.com>
Date: Tue, 20 Jun 2017 11:21:26 -0600

> Use Mellanox device ID definitions in the driver's mlx5 ID table so tools
> such as 'grep' and 'cscope' can be used to help find correlated material
> (such as INTx Masking quirks: d76d2fe05fd PCI: Convert Mellanox broken
> INTx quirks to be for listed devices only).
> 
> No functional change intended.
> 
> Signed-off-by: Myron Stowe <myron.stowe@redhat.com>

Applied to net-next, thanks.
