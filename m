From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Tue, 28 Feb 2012 20:53:47 -0500 (EST)
Message-ID: <20120228.205347.1718771650331094141.davem@davemloft.net>
References: <1330480210-30470-1-git-send-email-rodrigue@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mcgrof@frijolero.org, qca-linux-team@qualcomm.com,
	nic-devel@qualcomm.com, kgiori@qca.qualcomm.com,
	chris.snook@gmail.com, mathieu@qca.qualcomm.com, bryanh@quicinc.com
To: rodrigue@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330480210-30470-1-git-send-email-rodrigue@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Date: Tue, 28 Feb 2012 17:50:09 -0800

> The next patch adds the new QCA alx Ethernet driver that
> supercedes the atl1c Ethernet driver. For details please
> read the commit log of the patch. Given the size you can
> download the patch from:

What's wrong with making evolutionary fixes to atl1c instead
of replacing it wholesale?

This isn't the way to do it Luis.
