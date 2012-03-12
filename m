From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2: generic-receive-offload causes packet drops
Date: Mon, 12 Mar 2012 14:16:23 -0700
Message-ID: <1331586983.5136.48.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1331542469.10004.26.camel@tablet>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Peter Volkov" <pva@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2861 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756661Ab2CLVQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 17:16:35 -0400
In-Reply-To: <1331542469.10004.26.camel@tablet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-12 at 12:54 +0400, Peter Volkov wrote:
> So questions:  Is this expected? What information can we provide to
> debug is issue?
> 
Please provide ethtool -S on all the bnx2 devices that are experiencing
packet drops.  Thanks.
> 
