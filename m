From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: RE: [PATCH] qlcnic: Fix return value in qlcnic_probe()
Date: Tue, 30 Dec 2014 08:45:36 +0000
Message-ID: <262CB373A6D1F14F9B81E82F74F77D5A4717C763@avmb2.qlogic.org>
References: <1419926626-26624-1-git-send-email-xuyongjiande@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Yongjian Xu <xuyongjiande@gmail.com>
To: "xuyongjiande@163.com" <xuyongjiande@163.com>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419926626-26624-1-git-send-email-xuyongjiande@163.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: xuyongjiande@163.com [mailto:xuyongjiande@163.com]
> Sent: Tuesday, December 30, 2014 1:34 PM
> To: Shahed Shaikh; Dept-GE Linux NIC Dev
> Cc: netdev; linux-kernel; Yongjian Xu
> Subject: [PATCH] qlcnic: Fix return value in qlcnic_probe()
> 
> From: Yongjian Xu <xuyongjiande@gmail.com>
> 
> If the check of adapter fails and goes into the 'else' branch, the return value
> 'err' should not still be zero.
> 
> Signed-off-by: Yongjian Xu <xuyongjiande@gmail.com>
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    1 +
>  1 file changed, 1 insertion(+)

Acked-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Thanks,
Shahed
