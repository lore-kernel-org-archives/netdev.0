From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] wan/fsl_ucc_hdlc: remove reduplicative freed
 memory 'uhdlc_priv'
Date: Sat, 16 Jul 2016 20:22:21 -0700 (PDT)
Message-ID: <20160716.202221.2049218632762234450.davem@davemloft.net>
References: <1468550305-38571-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xiaobo.xie@nxp.com
To: qiang.zhao@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468550305-38571-1-git-send-email-qiang.zhao@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhao Qiang <qiang.zhao@nxp.com>
Date: Fri, 15 Jul 2016 10:38:24 +0800

> 'uhdlc_priv' has freed twice, drop the first one.
> 
> Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>

Applied.
