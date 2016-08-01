From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: enic: use correct type specifier
Date: Mon, 01 Aug 2016 13:44:24 -0700 (PDT)
Message-ID: <20160801.134424.634294641588596620.davem@davemloft.net>
References: <1469956208-32629-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, ssujith@cisco.com, _govind@gmx.com,
	neepatel@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469956208-32629-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Sun, 31 Jul 2016 11:10:08 +0200

> i is defined as unsigned.
> So print it with %u.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
