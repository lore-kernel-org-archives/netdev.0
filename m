From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] netns netfilter: netns propagation for /proc/net/*_tables_names
Date: Wed, 30 Jan 2008 16:17:31 +0100
Message-ID: <47A0950B.1020407@trash.net>
References: <20080125164429.GF6028@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53655 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbYA3PRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 10:17:47 -0500
In-Reply-To: <20080125164429.GF6028@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Propagate netns together with AF down to ->start/->next/->stop
> iterators. Choose table based on netns and AF for showing.

Applied.

