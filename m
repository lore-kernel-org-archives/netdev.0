From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xgene: Fix error handling
Date: Wed, 04 May 2016 14:02:37 -0400 (EDT)
Message-ID: <20160504.140237.1301311847350900607.davem@davemloft.net>
References: <1462284307-15401-1-git-send-email-mbrugger@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: mbrugger@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462284307-15401-1-git-send-email-mbrugger@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Brugger <mbrugger@suse.com>
Date: Tue,  3 May 2016 16:05:07 +0200

> When probe bails out with an error, we try to unregister the
> netdev before we have even registered it. Fix the goto statements
> for that.
> 
> Signed-off-by: Matthias Brugger <mbrugger@suse.com>

Applied.
