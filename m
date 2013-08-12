From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] net: davinci_mdio: use platform_{get,set}_drvdata()
Date: Mon, 12 Aug 2013 13:04:13 -0700 (PDT)
Message-ID: <20130812.130413.1869715009441960165.davem@davemloft.net>
References: <5208E231.60104@huawei.com>
	<520926CB.4020500@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clbchenlibo.chen@huawei.com, mugunthanvnm@ti.com,
	bigeasy@linutronix.de, prabhakar.csengg@gmail.com, b-liu@ti.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lizefan@huawei.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <520926CB.4020500@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 12 Aug 2013 22:17:47 +0400

>    Doesn't get described as well. I think you're mixing two types of
>    changes in one patchset.

Agreed, you're going to have to redo this entire patch set.
