From: Chris Rorvick <chris@rorvick.com>
Subject: Re: [PATCH] tipc: link: Remove unused function
Date: Sat, 17 Jan 2015 10:55:01 -0600
Message-ID: <CAEUsAPaJcx-3uzH5e-wfYgicejdPt8R88hZ5X8K2gH4eXHVaVw@mail.gmail.com>
References: <1421511231-14482-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:57476 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbbAQQzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 11:55:03 -0500
In-Reply-To: <1421511231-14482-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 17, 2015 at 10:13 AM, Rickard Strandqvist
<rickard_strandqvist@spectrumdigital.se> wrote:
> Remove the function tipc_link_get_max_pkt() that is not used anywhere.

This is already in the next tree:

commit 54fef04ad05f15984082c225fe47ce6af8ea1c5c
Author: Ying Xue <ying.xue@windriver.com>
Date:   Fri Jan 9 15:27:03 2015 +0800

    tipc: remove unused tipc_link_get_max_pkt routine

    Signed-off-by: Ying Xue <ying.xue@windriver.com>
    Tested-by: Tero Aho <Tero.Aho@coriant.com>
    Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
