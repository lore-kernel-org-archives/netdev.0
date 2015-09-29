From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net sysfs: Print link speed as signed integer
Date: Tue, 29 Sep 2015 14:56:37 -0700 (PDT)
Message-ID: <20150929.145637.1927733660071345122.davem@davemloft.net>
References: <1443445533-14474-1-git-send-email-alexander.stein@systec-electronic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alexander.stein@systec-electronic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443445533-14474-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Stein <alexander.stein@systec-electronic.com>
Date: Mon, 28 Sep 2015 15:05:33 +0200

> Otherwise 4294967295 (MBit/s) (-1) will be printed when there is no link.
> Documentation/ABI/testing/sysfs-class-net does not state if this shall be
> signed or unsigned.
> Also remove the now unused variable fmt_udec.
> 
> Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>

Applied, thanks.
