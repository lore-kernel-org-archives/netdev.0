From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 4/6] macvtap: adjust
 macvtap_skb_to_vnet_hdr() to be void
Date: Fri, 06 Dec 2013 12:53:33 -0500 (EST)
Message-ID: <20131206.125333.99786964245578540.davem@davemloft.net>
References: <1386310782-9378-1-git-send-email-zwu.kernel@gmail.com>
	<1386310782-9378-5-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	wuzhy@linux.vnet.ibm.com
To: zwu.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386310782-9378-5-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <zwu.kernel@gmail.com>
Date: Fri,  6 Dec 2013 14:19:40 +0800

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

As mentioned elsewhere, please combine the change that removes the return
value check with the change which adjusts the function return type to "void".

Thank you.
