From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Dec 1 (ethernet/mellanox)
Date: Thu, 1 Dec 2016 10:38:22 -0800
Message-ID: <c4b199c7-fcf4-c814-74f2-2ae6c457824c@infradead.org>
References: <20161201174235.21689436@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161201174235.21689436@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/30/16 22:42, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20161130:
> 

on i386:

when CONFIG_INET is not enabled:

drivers/built-in.o: In function `mlx5e_test_loopback':
en_selftest.c:(.text+0x690bde): undefined reference to `ip_send_check'
en_selftest.c:(.text+0x690c42): undefined reference to `udp4_hwcsum'


-- 
~Randy
