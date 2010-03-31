From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Severe regression in bnx2 driver with bonding in post
 2.6.30 kernels
Date: Wed, 31 Mar 2010 09:01:28 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421AF2CD5940@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <4BB3463A.2000801@openobjects.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "'Stuart Shelton'" <stuart@openobjects.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1947 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757162Ab0CaQBk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 12:01:40 -0400
In-Reply-To: <4BB3463A.2000801@openobjects.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stuart Shelton wrote:

> The Broadcom NetXtreme II driver appears to have a severe
> regression in
> all kernels post 2.6.30 - I've observed problems with 2.6.31, 2.6.32.
> and 2.6.33.
>
> The hardware impacted is an IBM Bladecenter LS21 Blade, model
> 7971.  We
> have a large number of these, and all are affected.
>

Can you provide me ethtool -i eth0 to see what the NVRAM-based
firmware version is?  Thanks.

