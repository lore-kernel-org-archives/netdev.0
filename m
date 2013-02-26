From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 0/8] Bugfix and mechanical works for Xen network
 driver
Date: Tue, 26 Feb 2013 11:07:33 +0800
Message-ID: <512C26F5.8020100@oracle.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, konrad.wilk@oracle.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41371 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387Ab3BZDHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 22:07:08 -0500
In-Reply-To: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What the version are these patches based on?
I tried v3.8-rc7 and 3.8-rc6, patch 3/8, 4/8 ... can not be merged 
successfully. Can you rebase it?

Thanks
Annie

On 2013-2-16 0:00, Wei Liu wrote:
> This patch series contains a small fix plus mechanical works for xen network
> driver.
>
>   * bug fix: don't bind kthread to specific cpu core
>   * allow host admin to unload netback
>   * multi-page ring support
>   * split event channels support
>
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
