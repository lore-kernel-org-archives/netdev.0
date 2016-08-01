From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] qed: do not use unitialized variable
Date: Mon, 01 Aug 2016 13:45:04 -0700 (PDT)
Message-ID: <20160801.134504.1892172575039074042.davem@davemloft.net>
References: <1469964292-3231-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469964292-3231-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Sun, 31 Jul 2016 13:24:52 +0200

> Do not write random bytes from the kernel stack when
> calling qed_wr.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
