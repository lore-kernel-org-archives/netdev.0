From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] ne: DeviceTree support.
Date: Mon, 18 Jan 2016 11:51:30 -0500 (EST)
Message-ID: <20160118.115130.332858656589845653.davem@davemloft.net>
References: <1452874786-21202-1-git-send-email-ysato@users.sourceforge.jp>
	<1453123957-19881-1-git-send-email-ysato@users.sourceforge.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ysato@users.sourceforge.jp
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453123957-19881-1-git-send-email-ysato@users.sourceforge.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshinori Sato <ysato@users.sourceforge.jp>
Date: Mon, 18 Jan 2016 22:32:36 +0900

> Add basic device tree support.
> Changes for v2
> - Add "national,dcr" property read check.
 ...
> +		national,dcr = <0x48>;

As has been explained, this national.dcr property is inappropriate.
