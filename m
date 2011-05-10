From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 4/10] ipvs: Use IP_VS_RT_MODE_* instead of magic
 constants.
Date: Wed, 11 May 2011 02:24:42 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1105110216200.4738@ja.ssi.bg>
References: <20110509.223118.260083861.davem@davemloft.net> <alpine.LFD.2.00.1105110123001.4532@ja.ssi.bg> <20110510.153051.71135029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49437 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752217Ab1EJXXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 19:23:51 -0400
In-Reply-To: <20110510.153051.71135029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 10 May 2011, David Miller wrote:

> > 	Fix more IP_VS_RT_MODE_* constants
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> > 
> > 	Following patch can be used after patch 4, eg. as
> > number 6 because patches 4 and 5 are ok and we are going to replace
> > patches 6 and 7.
> 
> Thanks Julian.
> 
> What I'm going to do is hold back the IPVS parts of the patches I
> posted last night.  In particular, I'll integrate this into the
> original patch #4.
> 
> And then we can work through the reimplementation ideas you posted to
> me in private email.
> 
> If you could post those ideas here on the list I'd appreciate it,
> so others can follow along and provide feedback.

	I think, I included the main things in the comments
with patch 7. I forgot to tell that I'll do some IPVS-IPv4 tests
tomorrow. May be Hans will test the patches too.

Regards

--
Julian Anastasov <ja@ssi.bg>
