From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] csiostor:Use firmware version from cxgb4/t4fw_version.h
Date: Wed, 04 Feb 2015 14:00:41 -0800 (PST)
Message-ID: <20150204.140041.405365438093253038.davem@davemloft.net>
References: <1422964106-4033-1-git-send-email-praveenm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	JBottomley@parallels.com, hch@infradead.org, hariprasad@chelsio.com
To: praveenm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755905AbbBDWAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 17:00:42 -0500
In-Reply-To: <1422964106-4033-1-git-send-email-praveenm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Praveen Madhavan <praveenm@chelsio.com>
Date: Tue,  3 Feb 2015 17:18:26 +0530

> This patch is to use firmware version macros from t4fw_version.h
> and also enables 40g T5 adapter.
> 
> Signed-off-by: Praveen Madhavan <praveenm@chelsio.com>

Applied.
