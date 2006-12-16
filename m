From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [patch 06/14] e1000: disable TSO on the 82544 with slab debugging
Date: Sat, 16 Dec 2006 12:18:54 -0800
Message-ID: <4807377b0612161218g645b4698xf0a395b07fcea94e@mail.gmail.com>
References: <4582B22B.5020004@garzik.org>
	 <E1GvNyb-0005yf-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, arjan@linux.intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:40926 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161463AbWLPUS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Dec 2006 15:18:56 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1151074uga
        for <netdev@vger.kernel.org>; Sat, 16 Dec 2006 12:18:54 -0800 (PST)
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <E1GvNyb-0005yf-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/15/06, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Any chance you could apply this patch instead? I've verified that this
> does resolve the problem on 82544.
>
> [NETDRV] e1000: Do not truncate TSO TCP header with 82544 workaround

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
