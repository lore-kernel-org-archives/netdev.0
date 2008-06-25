From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/8 v2] textsearch: fix textsearch for case insensitive searching
Date: Wed, 25 Jun 2008 12:52:33 +0200
Message-ID: <20080625105233.GK20815@postel.suug.ch>
References: <1214389493-21305-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:46188 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754251AbYFYKwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 06:52:12 -0400
Content-Disposition: inline
In-Reply-To: <1214389493-21305-1-git-send-email-joonwpark81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Joonwoo Park <joonwpark81@gmail.com> 2008-06-25 03:24
> The function textsearch_prepare has a new flag to support case
> insensitive searching.

Great work, I like it much better this way.

All patches look good.
