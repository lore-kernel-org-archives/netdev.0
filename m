From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: qlcnic: avoid superfluous assignement
Date: Mon, 01 Aug 2016 13:44:34 -0700 (PDT)
Message-ID: <20160801.134434.148137456195631735.davem@davemloft.net>
References: <1469959657-1342-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469959657-1342-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Sun, 31 Jul 2016 12:07:37 +0200

> Assigning NULL to parmeter dcb has no effect outside of the
> inlined function.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
