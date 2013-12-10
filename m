From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] macvtap: remove useless codes in
 macvtap_aio_read() and macvtap_recvmsg()
Date: Mon, 09 Dec 2013 20:36:41 -0500 (EST)
Message-ID: <20131209.203641.194782152490333573.davem@davemloft.net>
References: <1386363300-19040-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	wuzhy@linux.vnet.ibm.com
To: zwu.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386363300-19040-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <zwu.kernel@gmail.com>
Date: Sat,  7 Dec 2013 04:54:59 +0800

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> By checking related codes, it is impossible that ret > len or total_len,
> so we should remove some useless coeds in both above functions.
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Applied.
