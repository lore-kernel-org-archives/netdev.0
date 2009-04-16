From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 15:33:06 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161532350.22449@qirst.com>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com> <49E76906.2060205@hp.com> <alpine.DEB.1.10.0904161504090.15835@qirst.com> <49E786FE.6090304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:57753 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758935AbZDPTkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 15:40:23 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F356C82C2F0
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 15:50:16 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id RL6RKZIGejU0 for <netdev@vger.kernel.org>;
	Thu, 16 Apr 2009 15:50:10 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id CFF7882C2E2
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 15:50:04 -0400 (EDT)
In-Reply-To: <49E786FE.6090304@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, Eric Dumazet wrote:

> When you perform your test, you upgrade kernels of both machines ?

Yes. Both machines always run the same kernel version.

