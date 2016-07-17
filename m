From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] wan/fsl_ucc_hdlc: rewrite error handling to make
 it clearer
Date: Sat, 16 Jul 2016 20:22:25 -0700 (PDT)
Message-ID: <20160716.202225.254199322719866223.davem@davemloft.net>
References: <1468550305-38571-1-git-send-email-qiang.zhao@nxp.com>
	<1468550305-38571-2-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xiaobo.xie@nxp.com
To: qiang.zhao@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468550305-38571-2-git-send-email-qiang.zhao@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhao Qiang <qiang.zhao@nxp.com>
Date: Fri, 15 Jul 2016 10:38:25 +0800

> It was used err_xxx for labeled statement, it is
> not easy to understand, now use free_xxx for labeled
> statement.
> 
> Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>

Applied.
