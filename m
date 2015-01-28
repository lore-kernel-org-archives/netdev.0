From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Move firmware version MACRO to
 t4fw_version.h
Date: Tue, 27 Jan 2015 17:18:35 -0800 (PST)
Message-ID: <20150127.171835.2088395163984941384.davem@davemloft.net>
References: <1422369772-2215-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbbA1BSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 20:18:36 -0500
In-Reply-To: <1422369772-2215-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 27 Jan 2015 20:12:52 +0530

> Move firmware version MACRO to a new t4fw_version.h file so that csiostor driver
> can also use it.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
