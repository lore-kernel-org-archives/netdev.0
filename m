From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [net 1/3] igbvf: fix the bug when initializing the igbvf
Date: Tue, 01 May 2012 09:48:28 +0800
Message-ID: <4F9F40EC.1020004@gmail.com>
References: <1335827794-26992-1-git-send-email-jeffrey.t.kirsher@intel.com> <1335827794-26992-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, Samuel Liao <samuelliao@tencent.com>,
	Shan Wei <davidshan@tencent.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:32894 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757605Ab2EABrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 21:47:40 -0400
Received: by dadz8 with SMTP id z8so4794803dad.10
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 18:47:39 -0700 (PDT)
In-Reply-To: <1335827794-26992-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher said, at 2012/5/1 7:16:

> From: Shan Wei <shanwei88@gmail.com>


The "From" tag will be wrote in git log as Author of this patch.
It should be "From: Samuel Liao <samuelliao@tencent.com>", not me.

So, please resubmit it to David Miller.
Thanks.

> 
> Maybe it's a typo, but it cause that igbvf can't be initialized successfully.
> Set perm_addr value using valid dev_addr, although which is equal to hw.mac.addr.
> 
> Signed-off-by: Samuel Liao <samuelliao@tencent.com>
> Signed-off-by: Shan Wei <davidshan@tencent.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
