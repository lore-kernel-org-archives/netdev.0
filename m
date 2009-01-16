From: jpo234@netscape.net
Subject: Re: Sending complete IPv6 packets without bypassing netfilter/IPsec
Date: Fri, 16 Jan 2009 05:28:57 -0500
Message-ID: <8CB45DC5F36CAC1-2F30-897@webmail-stg-d07.sysops.aol.com>
References: <20090116064840.GA12399@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from imo-m13.mx.aol.com ([64.12.143.101]:12888 "EHLO
	imo-m13.mail.aol.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757714AbZAPKhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 05:37:46 -0500
In-Reply-To: <20090116064840.GA12399@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert,
once again thanks for your help! It works fine now.

Kind regards
  Joerg


-----Original Message-----
From: Herbert Xu <herbert@gondor.apana.org.au>
To: jpo234@netscape.net
Cc: netdev@vger.kernel.org
Sent: Fri, 16 Jan 2009 7:48 am
Subject: Re: Sending complete IPv6 packets without bypassing 
netfilter/IPsec

jpo234@netscape.net wrote:
>
> So, if you write "should have the same effect as IP_HDRINCL" does 
this
> mean "this is the way we designed it in Linux, so it should work" or

It's designed this way in Linux.

Cheers,
--
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt





