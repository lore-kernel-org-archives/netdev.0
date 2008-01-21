From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/3][NET] gen_estimator: list_empty() check in
	est_timer() fixed
Date: Mon, 21 Jan 2008 12:19:40 +0100
Message-ID: <20080121111940.GF1789@ff.dom.local>
References: <20080120155544.0a071675@deepthought> <20080121063455.GA981@ff.dom.local> <20080121064240.GB981@ff.dom.local> <20080121.023632.122420355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, slavon@bigtelecom.ru,
	kaber@trash.net, hadi@cyberus.ca, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:26267 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbYAULNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 06:13:08 -0500
Received: by nf-out-0910.google.com with SMTP id g13so238020nfb.21
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 03:13:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080121.023632.122420355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 02:36:32AM -0800, David Miller wrote:
...
> FWIW I agree that double-negatives are confusing and we should
> avoid them.

Right! No more: CHECKSUM_NONE, SOCK_NOSPACE, IFF_NOARP or KERN_NOTICE!

Jarek P.
