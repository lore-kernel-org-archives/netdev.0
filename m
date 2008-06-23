From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/8] textsearch: fix textsearch for case insensitive searching
Date: Tue, 24 Jun 2008 01:22:24 +0200
Message-ID: <20080623232224.GG20815@postel.suug.ch>
References: <1214034838-1270-1-git-send-email-joonwpark81@gmail.com> <485CB9F6.6050601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joonwoo Park <joonwpark81@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:60796 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbYFWXWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 19:22:06 -0400
Content-Disposition: inline
In-Reply-To: <485CB9F6.6050601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy <kaber@trash.net> 2008-06-21 10:21
> This looks fine to me, although a generic flags argument
> would prevent changing all users again next time someone
> wants to add a feature. But I'll leave that decision to
> Thomas.

I agree, I'd favour a general flag for this as well.

> Thomas, since there are some netfilter patches that depend
> on the textsearch patches, do you want me to apply those as
> well (haven't reviewed them yet though)?

Sure.
