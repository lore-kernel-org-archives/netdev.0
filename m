From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/8 v2] textsearch: fix Knuth-Morris-Pratt for case insensitive
 searching
Date: Wed, 25 Jun 2008 13:01:08 +0200
Message-ID: <48622574.9020201@trash.net>
References: <> <1214389500-21365-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49954 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208AbYFYLBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 07:01:16 -0400
In-Reply-To: <1214389500-21365-1-git-send-email-joonwpark81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> Fix Knuth-Morris-Pratt algorithm to have capability of case insensitive
> searching

Also applied, thanks.
