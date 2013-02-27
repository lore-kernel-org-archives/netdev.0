From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix UDP checksum for 57710/57711.
Date: Wed, 27 Feb 2013 13:12:11 -0500 (EST)
Message-ID: <20130227.131211.135994908660158725.davem@davemloft.net>
References: <1361959499-3968-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, yuvalmin@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932557Ab3B0SMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 13:12:13 -0500
In-Reply-To: <1361959499-3968-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 27 Feb 2013 12:04:59 +0200

> Since commit 86564c3f "bnx2x: Remove many sparse warnings" UDP
> csum offload is broken for 57710/57711. Fix return value.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>

Applied.
