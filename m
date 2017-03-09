From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCHv2 3/5] rds: ib: remove redundant ib_dealloc_fmr
Date: Thu, 9 Mar 2017 10:42:14 +0100
Message-ID: <e838822e-11ae-5259-62a1-7fb2b5f0ca0e@suse.de>
References: <cffc93fa-f4e6-e61e-54c6-67d6501dd78c@suse.de>
 <1489051243-27108-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
To: Zhu Yanjun <yanjun.zhu@oracle.com>, santosh.shilimkar@oracle.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48035 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754376AbdCIJmR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 04:42:17 -0500
In-Reply-To: <1489051243-27108-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2017 10:20 AM, Zhu Yanjun wrote:
> The function ib_dealloc_fmr will never be called. As such, it should
> be removed.
> 
> Cc: Joe Jin <joe.jin@oracle.com>
> Cc: Junxiao Bi <junxiao.bi@oracle.com>
> Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
> ---

Reviewed-by: Johannes Thumshirn <jthumshirn@suse.de>


-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
