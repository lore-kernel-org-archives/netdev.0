From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.27] cxgb3: Allow 64KB firmware images.
Date: Tue, 29 Jul 2008 17:49:52 -0400
Message-ID: <488F9080.1080104@garzik.org>
References: <20080726204056.1366.28529.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, rdreier@cisco.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43729 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757381AbYG2Vt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 17:49:56 -0400
In-Reply-To: <20080726204056.1366.28529.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Wise wrote:
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

applied


