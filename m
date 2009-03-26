From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: network traffic stop with 2.6.29 after ftp put
Date: Thu, 26 Mar 2009 09:52:06 +0100
Message-ID: <BAY103-DAV9C5EA8FA3DE735A3D64B6B2910@phx.gbl>
References: <BAY103-DAV683AFCEC466B8F2E6D8EBB2930@phx.gbl> <BAY103-DAV100CC8DA92566937097718B2930@phx.gbl> <49C8C26B.7070802@cosmosbay.com> <BAY103-DAV11986CBE87674225EDC31EB2930@phx.gbl> <49C8E7FF.7020906@cosmosbay.com> <BAY103-DAV1251BBA7FBA4243359906AB2930@phx.gbl> <BAY103-DAV114D2F6EE08154E75BB064B2900@phx.gbl> <20090325120932.GB6351@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Eric Dumazet" <dada1@cosmosbay.com>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s28.bay0.hotmail.com ([65.54.246.100]:28937 "EHLO
	bay0-omc1-s28.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751034AbZCZIwv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 04:52:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

> On Wed, Mar 25, 2009 at 09:10:29AM +0100, Marco Berizzi wrote:
> >
> > no, it doesn't fix the problem.
> > This morning I got the same problem
> > (I was reading the kernel mailing list
> > on lkml.indiana.edu with firefox)
> 
> Please try the full GRO revert for netif_rx that I just posted.

ok, I have reverted the GRO and I have not
got the problem.

Thanks.
