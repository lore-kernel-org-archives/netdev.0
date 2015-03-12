From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/4] rhashtable: Use head_hashfn instead of obj_raw_hashfn
Date: Thu, 12 Mar 2015 14:12:21 +0000
Message-ID: <20150312141221.GB4001@casper.infradead.org>
References: <20150312034923.GA14415@gondor.apana.org.au>
 <E1YVu7v-0003lg-9c@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50299 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902AbbCLOMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 10:12:22 -0400
Content-Disposition: inline
In-Reply-To: <E1YVu7v-0003lg-9c@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/15 at 02:49pm, Herbert Xu wrote:
> Now that we don't have cross-table hashes, we no longer need to
> keep the entire hash value so all users of obj_raw_hashfn can
> use head_hashfn instead.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
