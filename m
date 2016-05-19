From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: ehea: avoid null pointer dereference
Date: Thu, 19 May 2016 11:26:11 -0700 (PDT)
Message-ID: <20160519.112611.1012146432917823656.davem@davemloft.net>
References: <1463516934-10115-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463516934-10115-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Tue, 17 May 2016 22:28:54 +0200

> ehea_get_port may return NULL. Do not dereference NULL value.
> 
> Fixes: 8c4877a4128e ("ehea: Use the standard logging functions")
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
