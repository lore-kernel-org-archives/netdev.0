From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]atl1c:use common_task instead of reset_task
 and link_chg_task
Date: Tue, 08 Dec 2009 20:48:24 -0800 (PST)
Message-ID: <20091208.204824.04911690.davem@davemloft.net>
References: <1260177418354-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmatei@profis.ro, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757039AbZLIEsY@vger.kernel.org>
In-Reply-To: <1260177418354-git-send-email-jie.yang@atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <jie.yang@atheros.com>
Date: Mon, 7 Dec 2009 17:16:58 +0800

> From: Jie Yang <jie.yang@atheros.com>
> 
> use common_task instead of reset_task and link_chg_task, so it fix "call cancel_work_sync
> from the work itself".
> 
> Signed-off-by: Jie Yang <jie.yang@atheros.com>

Applied.
