From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: use the correct size for _simple_hash()
Date: Mon, 28 Feb 2011 13:21:48 -0800 (PST)
Message-ID: <20110228.132148.116384901.davem@davemloft.net>
References: <1298885668-3917-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298885668-3917-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Mon, 28 Feb 2011 17:34:28 +0800

> Clearly it should be the size of ->ip_dst here.
> Although this is harmless, but it still reads odd.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>

Applied to net-next-2.6, thanks.
