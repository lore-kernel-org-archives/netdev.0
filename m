From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] chelsio: cxgb4: fix sparse warning
Date: Thu, 05 Feb 2015 16:05:22 -0800 (PST)
Message-ID: <20150205.160522.373864854025762797.davem@davemloft.net>
References: <1423149609-24108-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: prabhakar.csengg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423149609-24108-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Date: Thu,  5 Feb 2015 15:20:09 +0000

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warning:
> 
> cxgb4_dcb.c:25:6: warning: symbol 'dcb_ver_array' was not declared. Should it be static?
> 
> Alongside making it const.
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied.
