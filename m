From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 2 Sep 2009 13:13:44 -0500 (CDT)
Message-ID: <alpine.DEB.1.10.0909021313160.27987@V090114053VZO-1>
References: <20090902081429.GB4878@ff.dom.local> <4A9E2CC7.1010103@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:36417 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752360AbZIBOO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 10:14:56 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4192E82C32A
	for <netdev@vger.kernel.org>; Wed,  2 Sep 2009 10:16:39 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id i92gI1d7euXq for <netdev@vger.kernel.org>;
	Wed,  2 Sep 2009 10:16:34 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id ACE6982C823
	for <netdev@vger.kernel.org>; Wed,  2 Sep 2009 10:16:12 -0400 (EDT)
In-Reply-To: <4A9E2CC7.1010103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Sep 2009, Eric Dumazet wrote:

> Same name "eth0" is displayed, that might confuse parsers...
>
> What naming convention should we choose for multiqueue devices ?

eth0/tx<number> ?


