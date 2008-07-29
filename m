From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2.6.27] cxgb3: Allow 64KB firmware images.
Date: Mon, 28 Jul 2008 18:25:28 -0700
Message-ID: <200807281825.29113.divy@chelsio.com>
References: <20080726204056.1366.28529.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, rdreier@cisco.com
To: "Steve Wise" <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:3818 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbYG2B04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 21:26:56 -0400
In-Reply-To: <20080726204056.1366.28529.stgit@dell3.ogc.int>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 26 July 2008 01:40:56 pm Steve Wise wrote:
> Jeff,
>
> This small patch is needed to allow loading the 7.0 firmware, which is
> required for 2.6.27.  Any chance of this making 2.6.27-rc1?
>
> Thanks,
>
> Steve.
>
> ----
> cxgb3: Allow 64KB firmware images.
>
> Starting with FW version 7.0, the driver needs to allow larger images.
>
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>

Acked-by: Divy Le Ray <divy@chelsio.com>
