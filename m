From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Fri, 17 Apr 2009 09:47:42 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904170947301.11877@qirst.com>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com> <49E78A79.6050604@cosmosbay.com> <alpine.DEB.1.10.0904161553160.23632@qirst.com> <1239919037.12883.15.camel@HP1>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:53342 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758355AbZDQNy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 09:54:58 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1383C82C16E
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 10:04:57 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7BX2hJfj3RjA for <netdev@vger.kernel.org>;
	Fri, 17 Apr 2009 10:04:57 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5A1BC82C383
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 10:04:52 -0400 (EDT)
In-Reply-To: <1239919037.12883.15.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, Michael Chan wrote:

> It will not matter if you use the same out-of-tree driver when switching
> kernels.  If you use in-tree driver, the firmware may have changed
> between kernel versions.

The in tree driver was used.

