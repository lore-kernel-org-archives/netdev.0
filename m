From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/5] netns netfilter: change xt_table_register() return
 value convention
Date: Tue, 22 Jan 2008 17:49:38 +0100
Message-ID: <47961EA2.2040700@trash.net>
References: <20080121145205.GF27615@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53586 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbYAVQuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 11:50:14 -0500
In-Reply-To: <20080121145205.GF27615@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> Switch from 0/-E to ptr/PTR_ERR convention.

Applied.

