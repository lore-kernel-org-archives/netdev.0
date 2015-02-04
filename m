From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] gianfar: correct the bad expression while writing
 bit-pattern
Date: Wed, 04 Feb 2015 13:55:52 -0800 (PST)
Message-ID: <20150204.135552.872538804146042727.davem@davemloft.net>
References: <54B3D899.5060204@freescale.com>
	<1422948722-16864-1-git-send-email-sanjeev_sharma@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, matei.pavaluca@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sanjeev_sharma@mentor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422948722-16864-1-git-send-email-sanjeev_sharma@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sanjeev Sharma <sanjeev_sharma@mentor.com>
Date: Tue, 3 Feb 2015 13:02:02 +0530

> This patch correct the bad expression while writing the
> bit-pattern from software's buffer to hardware registers.
> 
> Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
> ---
> Changes in v3:
>   - corrected the expression by introducing tab->fe[i].prop.

Applied, thanks.
