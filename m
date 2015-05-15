From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next] net: fix two sparse errors
Date: Fri, 15 May 2015 18:26:02 +0200
Message-ID: <20150515162602.GA1757@via.ecp.fr>
References: <20150515143506.GA5019@via.ecp.fr>
 <CALx6S35tiLs=RU9t9XriakDgD-66N4F2FKrpQYe6--XhBn=_Ng@mail.gmail.com>
 <20150515155441.GA24669@via.ecp.fr>
 <20150515.121942.697185533705459189.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: tom@herbertland.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from artikodin.via.ecp.fr ([138.195.130.75]:58936 "EHLO
	artikodin.via.ecp.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934533AbbEOQ0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 12:26:07 -0400
Content-Disposition: inline
In-Reply-To: <20150515.121942.697185533705459189.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-05-15, 12:19:42 -0400, David Miller wrote:
> From: Sabrina Dubroca <sd@queasysnail.net>
> Date: Fri, 15 May 2015 17:54:41 +0200
> 
> > Hi Tom,
> > 
> > 2015-05-15, 11:27:25 -0400, Tom Herbert wrote:
> >> Hi Sabrina,
> >> 
> >> We returned the checksum value since that may be of interest to the
> >> caller at some point.
> > 
> > Hmm, I thought "we may need that some day" was not a valid argument?
> 
> I think Tom's time frame for "some day" is really small and he
> should be accomodated.

Okay. Sorry again.

-- 
Sabrina
