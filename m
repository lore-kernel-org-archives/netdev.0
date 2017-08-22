From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: make ptp_clock_info const
Date: Tue, 22 Aug 2017 11:05:08 -0700 (PDT)
Message-ID: <20170822.110508.2235256435893067147.davem@davemloft.net>
References: <1503335210-16179-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, nicolas.ferre@microchip.com,
        richardcochran@gmail.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, cmetcalf@mellanox.com,
        adi-buildroot-devel@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503335210-16179-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Mon, 21 Aug 2017 22:36:50 +0530

> Make these const as they are only used in a copy operation.
> Done using Coccinelle.
 ...
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.
