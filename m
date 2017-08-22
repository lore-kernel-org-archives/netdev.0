From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: ethernet: make ptp_clock_info const
Date: Tue, 22 Aug 2017 08:24:48 +0200
Message-ID: <20170822062448.hcr5z67pvh5dc3bw@localhost>
References: <1503335210-16179-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr, nicolas.ferre@microchip.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        cmetcalf@mellanox.com, adi-buildroot-devel@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1503335210-16179-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 10:36:50PM +0530, Bhumika Goyal wrote:
> Make these const as they are only used in a copy operation.
> Done using Coccinelle.

Acked-by: Richard Cochran <richardcochran@gmail.com>
