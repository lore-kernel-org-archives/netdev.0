From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 v2] dsa: b53: remove redundant if
Date: Mon, 01 Aug 2016 13:45:09 -0700 (PDT)
Message-ID: <20160801.134509.1705054795468117839.davem@davemloft.net>
References: <a26b33b7-f051-b84c-684a-abb586991513@cogentembedded.com>
	<1469965353-3496-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469965353-3496-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Sun, 31 Jul 2016 13:42:33 +0200

> For pdata == null the code leaves with an error.
> There is no need to check the condition again.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
