From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next] net: fix two sparse errors
Date: Fri, 15 May 2015 17:54:41 +0200
Message-ID: <20150515155441.GA24669@via.ecp.fr>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
 <1431401204-731380-6-git-send-email-tom@herbertland.com>
 <1431405215.566.56.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431406237.566.59.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S36nVmVxo2QADh-Qmyk7+TU=Zo4vAmRtU1qtDtRqFWGAJg@mail.gmail.com>
 <1431446777.566.87.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431694087.27831.99.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150515143506.GA5019@via.ecp.fr>
 <CALx6S35tiLs=RU9t9XriakDgD-66N4F2FKrpQYe6--XhBn=_Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from artikodin.via.ecp.fr ([138.195.130.75]:58124 "EHLO
	artikodin.via.ecp.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934533AbbEOPym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 11:54:42 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S35tiLs=RU9t9XriakDgD-66N4F2FKrpQYe6--XhBn=_Ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

2015-05-15, 11:27:25 -0400, Tom Herbert wrote:
> Hi Sabrina,
> 
> We returned the checksum value since that may be of interest to the
> caller at some point.

Hmm, I thought "we may need that some day" was not a valid argument?


Thanks,
-- 
Sabrina
