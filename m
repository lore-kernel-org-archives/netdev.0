From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] ip: vfinfo: remove code duplication for
 IFLA_VF_RSS_QUERY_EN
Date: Fri, 16 Dec 2016 17:43:11 +0100
Message-ID: <20161216164311.GN13857@orbyte.nwl.cc>
References: <20161216163605.19728-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Julien Fortin <julien@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59223 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934179AbcLPQnN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 11:43:13 -0500
Content-Disposition: inline
In-Reply-To: <20161216163605.19728-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 16, 2016 at 05:36:05PM +0100, Julien Fortin wrote:
> From: Julien Fortin <julien@cumulusnetworks.com>
> 
> Fixes: 4fb4a10e120b1 ("ipaddress: Print IFLA_VF_QUERY_RSS_EN setting”)
> 
> Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>

Oh! Looks like Git messed up during a rebase and the obviously wrong
result was overlooked.

Acked-by: Phil Sutter <phil@nwl.cc>
