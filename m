From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH v2] qlge: call ql_core_dump() only if dump memory was
 allocated.
Date: Mon, 23 Sep 2013 04:41:48 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E46C8996B@avmb2.qlogic.org>
References: <1379712077-31750-1-git-send-email-malahal@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Malahal Naineni <malahal@us.ibm.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:14911 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753169Ab3IWElw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 00:41:52 -0400
In-Reply-To: <1379712077-31750-1-git-send-email-malahal@us.ibm.com>
Content-Language: en-US
Content-ID: <F6F4CED3AAB6DD479C209C85CCBF2C86@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/20/13 2:21 PM, "Malahal Naineni" <malahal@us.ibm.com> wrote:

>Also changed a log message to indicate that memory was not allocated
>instead of memory not available!
>
>Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
>---
> drivers/net/ethernet/qlogic/qlge/qlge_dbg.c | 4 ++--
> drivers/net/ethernet/qlogic/qlge/qlge_mpi.c | 2 +-
> 2 files changed, 3 insertions(+), 3 deletions(-)

Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Thanks,
    Jitendra
