From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iproute2: drop equalize support.
Date: Fri, 27 Mar 2009 19:37:09 +0100
Message-ID: <49CD1CD5.4080105@trash.net>
References: <20090314163735.GA9762@amd64.fatal.se> <20090327112947.27a5ae7a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andreas Henriksson <andreas@fatal.se>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37358 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbZC0ShT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 14:37:19 -0400
In-Reply-To: <20090327112947.27a5ae7a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> applied, i think this was part of the aborted effort at more complex
> multipath support. If it ever returns, we can re-enable it.

Its actually a lot older than that, it used to be an external patch
in the 2.4 era for per-packet multipath routing. I don't think
anyone will miss it :)


