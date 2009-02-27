From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Multicast packet loss
Date: Fri, 27 Feb 2009 13:40:51 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0902271340320.9381@qirst.com>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kenny Chang <kchang@athenacr.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:41557 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754867AbZB0SuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 13:50:03 -0500
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D90C082C912
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 13:54:57 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sof6IJu+Kssl for <netdev@vger.kernel.org>;
	Fri, 27 Feb 2009 13:54:54 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5032082C913
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 13:54:50 -0500 (EST)
In-Reply-To: <49838213.90700@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Jan 2009, Eric Dumazet wrote:

> 2.6.29-rc contains UDP receive improvements (lockless)
>
> Problem is multicast handling was not yet updated, but could be :)

When will that happen?

