From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RESEND PATCH iproute2] tc: fix compilation with old gcc (<
 4.6) (bis)
Date: Fri, 5 Feb 2016 11:50:08 +1100
Message-ID: <20160205115008.349c6c34@samsung9>
References: <56B08760.7040204@6wind.com>
	<569e50f6be2b43c4a7e1483e295da271@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"julien.floret@6wind.com" <julien.floret@6wind.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35883 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbcBEAuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 19:50:20 -0500
Received: by mail-pf0-f170.google.com with SMTP id n128so58391176pfn.3
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 16:50:19 -0800 (PST)
In-Reply-To: <569e50f6be2b43c4a7e1483e295da271@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Feb 2016 08:25:00 +0000
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Commit 8f80d450c3cb ("tc: fix compilation with old gcc (< 4.6)") was reverted
> to ease the merge of the net-next branch.
> 
> Here is the new version.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied
