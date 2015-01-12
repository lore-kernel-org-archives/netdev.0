From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Driver: Vmxnet3: Reinitialize vmxnet3 backend
 on wakeup from hibernate
Date: Mon, 12 Jan 2015 16:44:43 -0500 (EST)
Message-ID: <20150112.164443.1375211702342773207.davem@davemloft.net>
References: <1420845554-491-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	smurali@vmware.com
To: skhare@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420845554-491-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shrikrishna Khare <skhare@vmware.com>
Date: Fri,  9 Jan 2015 15:19:14 -0800

> Failing to reinitialize on wakeup results in loss of network connectivity for
> vmxnet3 interface.
> 
> Signed-off-by: Srividya Murali <smurali@vmware.com>
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> Reviewed-by: Shreyas N Bhatewara <sbhatewara@vmware.com>

Applied, thanks.
