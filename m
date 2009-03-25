From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: network traffic stop with 2.6.29 after ftp put
Date: Wed, 25 Mar 2009 09:10:29 +0100
Message-ID: <BAY103-DAV114D2F6EE08154E75BB064B2900@phx.gbl>
References: <BAY103-DAV683AFCEC466B8F2E6D8EBB2930@phx.gbl> <BAY103-DAV100CC8DA92566937097718B2930@phx.gbl> <49C8C26B.7070802@cosmosbay.com> <BAY103-DAV11986CBE87674225EDC31EB2930@phx.gbl> <49C8E7FF.7020906@cosmosbay.com> <BAY103-DAV1251BBA7FBA4243359906AB2930@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>,
	"Herbert Xu" <herbert@gondor.apana.org.au>
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s2.bay0.hotmail.com ([65.54.246.138]:9936 "EHLO
	bay0-omc2-s2.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750768AbZCYILM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 04:11:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi wrote:
> Eric Dumazet wrote:
> 
> > You probably have the problem Ingo reported on lkml, please try Herbert
> > fix :
> > 
> > http://marc.info/?l=linux-kernel&m=123790184128396&w=2
> 
> yes this patch fix the problem.
> Thanks Eric and thanks Herbert.

no, it doesn't fix the problem.
This morning I got the same problem
(I was reading the kernel mailing list
on lkml.indiana.edu with firefox)
