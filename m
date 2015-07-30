From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] Add MDIO support to ThunderX NIC driver
Date: Wed, 29 Jul 2015 17:18:07 -0700 (PDT)
Message-ID: <20150729.171807.2080139287211431874.davem@davemloft.net>
References: <1438121533-21528-1-git-send-email-mohun106@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	ddaney@caviumnetworks.com, sgoutham@caviumnetworks.com,
	rchintakuntla@cavium.com
To: mohun106@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438121533-21528-1-git-send-email-mohun106@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: mohun106@gmail.com
Date: Tue, 28 Jul 2015 15:12:10 -0700

> This patch series adds MDIO support to ThunderX NIC driver by making use
> of existing mdio-octeon driver. In the process modified the mdio-octeon
> driver to work on both Octeon and ThunderX platforms.
> 
> * From v1:
>   - Removed default selection in Kconfig for MDIO_OCTEON
>   - Replace uint64 with u64 as suggested by David Daney

Series applied, thanks.
