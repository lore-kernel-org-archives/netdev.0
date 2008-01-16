From: Frans Pop <elendil@planet.nl>
Subject: Re: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Wed, 16 Jan 2008 09:56:08 +0100
Message-ID: <200801160956.09053.elendil@planet.nl>
References: <200801151504.10047.elendil@planet.nl> <36D9DB17C6DE9E40B059440DB8D95F52042FA541@orsmsx418.amr.corp.intel.com> <20080115.210214.170759690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, slavon@bigtelecom.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpsmtp-eml15.KPNXCHANGE.COM ([213.75.38.115]:17882 "EHLO
	hpsmtp-eml15.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751308AbYAPI4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 03:56:12 -0500
In-Reply-To: <20080115.210214.170759690.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 16 January 2008, David Miller wrote:
> Ok, here is the patch I'll propose to fix this.  The goal is to make
> it as simple as possible without regressing the thing we were trying
> to fix.

Looks good to me. Tested with -rc8.

Cheers,
FJP
