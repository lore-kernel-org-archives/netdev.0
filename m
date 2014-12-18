From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: drop the packet when fails to do software
 segmentation or header check
Date: Thu, 18 Dec 2014 15:39:12 -0500 (EST)
Message-ID: <20141218.153912.942123862967427213.davem@davemloft.net>
References: <1418882239-6720-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418882239-6720-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Thu, 18 Dec 2014 13:57:19 +0800

> Fixes cecda693a969816bac5e470e1d9c9c0ef5567bca

Please correct this fixes tag, it should be of the form:

Fixes: $(SHA1) ("header text of commit message")

The SHA1 ID should be reduced to 12 digits of significance.
