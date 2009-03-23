From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Linux kernel support for mesh network multicast routing
Date: Mon, 23 Mar 2009 14:16:22 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0903231413580.12221@qirst.com>
References: <200903230923.05372.hrogge@googlemail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Henning Rogge <hrogge@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:39825 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590AbZCWSaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 14:30:04 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EFD8E82CB88
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 14:26:44 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Etmm+u4xErTt for <netdev@vger.kernel.org>;
	Mon, 23 Mar 2009 14:26:37 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id BFC3882CE73
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2009 14:26:33 -0400 (EDT)
In-Reply-To: <200903230923.05372.hrogge@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Mar 2009, Henning Rogge wrote:

> At the moment OLSR.org does only support unicast routing (by setting routes in
> the linux kernel to do the hop-by-hop forwarding), but we would like to add
> the ability to use multicast too. OLSR is a proactive routing protocol, so
> each routing daemon has information about the whole network topology.

Have you looked at mrouted?
