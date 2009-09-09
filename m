From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Wed, 9 Sep 2009 10:01:06 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:40418 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751417AbZIIOCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 10:02:09 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4F97A82C2EB
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 10:03:07 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hTTez74RXXyl for <netdev@vger.kernel.org>;
	Wed,  9 Sep 2009 10:03:02 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0A6EE82C389
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 10:03:02 -0400 (EDT)
In-Reply-To: <4AA6E039.4000907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Sep 2009, Eric Dumazet wrote:

> In order to reproduce this here, could you tell me if you use
>
> Producer linux-2.6.22 -> Receiver 2.6.22
> Producer linux-2.6.31 -> Receiver 2.6.31

I use the above setup.

