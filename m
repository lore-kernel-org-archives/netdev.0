From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] hv_netvsc: cleanup after untangling the
 pointer mess
Date: Mon, 23 May 2016 15:13:23 -0700 (PDT)
Message-ID: <20160523.151323.522872084486431802.davem@davemloft.net>
References: <1464018638-22000-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, haiyangz@microsoft.com,
	kys@microsoft.com
To: vkuznets@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464018638-22000-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Mon, 23 May 2016 17:50:33 +0200

> After we made traveling through our internal structures explicit it became
> obvious that some functions take arguments they don't need just to do
> redundant pointer travel and get to what they really need while their
> callers already have the required information.
> 
> This is just a cleanup series with no functional changes intended. It
> doesn't pretend to be complete, additional cleanup of other functions may
> follow.

Cleanups and new features should not be submitted at this time since the
net-next tree is closed.
