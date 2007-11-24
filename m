From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: add support for supporting 10000baseT
Date: Fri, 23 Nov 2007 20:55:42 -0500
Message-ID: <4747849E.5040009@garzik.org>
References: <20071107162420.5102.26358.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52741 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753169AbXKXBzo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 20:55:44 -0500
In-Reply-To: <20071107162420.5102.26358.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> there is missing support in ethtool for reporting 10000baseT
> as SUPPORTED_10000baseT_Full.  The code seems to be half
> implemented because the "advertising" field has the implementation.
> 
> this patch just adds it for supported reporting.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  ethtool.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)

applied


