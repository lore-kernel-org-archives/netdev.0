From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: Add asm/cacheflush.h
Date: Mon, 26 Oct 2009 17:19:56 -0700 (PDT)
Message-ID: <20091026.171956.110203653.davem@davemloft.net>
References: <29ab51dc0910261649p2fb22799o5cc70a71dff0f1dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	lethal@linux-sh.org
To: iwamatsu@nigauri.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <29ab51dc0910261649p2fb22799o5cc70a71dff0f1dd@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Date: Tue, 27 Oct 2009 08:49:50 +0900

> Add include asm/cacheflush.h,  because declaration of __flush_purge_region
> moved to asm/cacheflush.h.
> 
> Signed-off-by: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>

Applied, thanks.
