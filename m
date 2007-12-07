From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 0/2] cxgb3 - driver update
Date: Thu, 06 Dec 2007 18:50:36 -0800
Message-ID: <4758B4FC.4010307@chelsio.com>
References: <4756EA9D.1070204@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>,
	Wen Xiong <wenxiong@us.ibm.com>
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31093 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbXLGCvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 21:51:10 -0500
In-Reply-To: <4756EA9D.1070204@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> Jeff,
>
> I'm submitting a patch series for inclusion in 2.6.25.
> The patches are built against netdev#upstream.
>
> Here is a brief description:
> - Update GPIO pinning and MAC support for T3C adapters
> - Enable parity error detection.
Jeff,

I posted a third patch to fix the EEH code and add a missing
softirq blocking call.

Cheers,
Divy
