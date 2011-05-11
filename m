From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 4/10] ipvs: Use IP_VS_RT_MODE_* instead of magic constants.
Date: Wed, 11 May 2011 08:02:00 +0200
Message-ID: <201105110802.01963.hans.schillstrom@ericsson.com>
References: <20110509.223118.260083861.davem@davemloft.net> <20110510.153051.71135029.davem@davemloft.net> <alpine.LFD.2.00.1105110216200.4738@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:59092 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755994Ab1EKVrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 17:47:11 -0400
In-Reply-To: <alpine.LFD.2.00.1105110216200.4738@ja.ssi.bg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
On Wednesday 11 May 2011 01:24:42 Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 10 May 2011, David Miller wrote:
> 
> > > 	Fix more IP_VS_RT_MODE_* constants
> > > 
> > > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > > ---
> > > 
> > > 	Following patch can be used after patch 4, eg. as
> > > number 6 because patches 4 and 5 are ok and we are going to replace
> > > patches 6 and 7.
> > 
> > Thanks Julian.
> > 
> > What I'm going to do is hold back the IPVS parts of the patches I
> > posted last night.  In particular, I'll integrate this into the
> > original patch #4.
> > 
> > And then we can work through the reimplementation ideas you posted to
> > me in private email.
> > 
> > If you could post those ideas here on the list I'd appreciate it,
> > so others can follow along and provide feedback.
> 
> 	I think, I included the main things in the comments
> with patch 7. I forgot to tell that I'll do some IPVS-IPv4 tests
> tomorrow. May be Hans will test the patches too.

It all looks good to me, I'll do some tests today.

> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
