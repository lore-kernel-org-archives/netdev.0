From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/3][NET] gen_estimator: list_empty() check in
	est_timer() fixed
Date: Mon, 21 Jan 2008 07:42:40 +0100
Message-ID: <20080121064240.GB981@ff.dom.local>
References: <20080120234959.GB2691@ami.dom.local> <20080120155544.0a071675@deepthought> <20080121063455.GA981@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:29534 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbYAUGgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 01:36:06 -0500
Received: by ug-out-1314.google.com with SMTP id z38so835046ugc.16
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 22:36:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080121063455.GA981@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 07:34:55AM +0100, Jarek Poplawski wrote:
...
> BTW, I've forgotten to mention with patch 1/3 that this checking with
> warning on gen_new_estimator() double call should be only temporary,
> and after more testing gen_estimator structure could be probably
> decreased after removing bstats and rate_est fields.

Hmm, let's forget about this again: it's too early in the morning...

Jarek P.
