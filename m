From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 07:26:42 -0500
Message-ID: <1200572803.4508.16.camel@localhost>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au>
	 <1200533980.4451.100.camel@localhost>
	 <20080117021743.GA5182@gondor.apana.org.au> <478EED98.6080603@iki.fi>
	 <20080117111106.GA8932@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:20633 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755878AbYAQM0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 07:26:55 -0500
Received: by py-out-1112.google.com with SMTP id u52so943864pyb.10
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 04:26:52 -0800 (PST)
In-Reply-To: <20080117111106.GA8932@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-17-01 at 22:11 +1100, Herbert Xu wrote:

> Sure racoon uses pfkey but the question is does it use pfkey dumping?
> 

it does when trying to purge phase 2 SAs...

cheers,
jamal

