From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Panic with demuxed ipv4 multicast udp sockets on 4.0.4
Date: Wed, 12 Aug 2015 11:05:53 -0700
Message-ID: <1439402753.29802.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2ddbe291fff643899849eb068ef219e0@svr-chch-ex1.atlnz.lc>
	 <1438234969.20182.124.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1438235159.20182.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0dd213ace919410da723ac93892d1f4d@svr-chch-ex1.atlnz.lc>
	 <1438337866.2748.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1438341449.2748.9.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0054031415584f58aeba627a5ca5aefc@svr-chch-ex1.atlnz.lc>
	 <CALCkm3cqbST9ZDmnw4gnGyTFM2KZrPPd3+D4UxtP73yN8oMOJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Gregory Hoggarth <Gregory.Hoggarth@alliedtelesis.co.nz>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33354 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259AbbHLSFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 14:05:55 -0400
Received: by pdrh1 with SMTP id h1so9848722pdr.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 11:05:54 -0700 (PDT)
In-Reply-To: <CALCkm3cqbST9ZDmnw4gnGyTFM2KZrPPd3+D4UxtP73yN8oMOJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-12 at 09:13 -0700, Alex Gartrell wrote:
> Hey Gregory,
> 
> On Sun, Aug 2, 2015 at 2:28 PM, Gregory Hoggarth
> <Gregory.Hoggarth@alliedtelesis.co.nz> wrote:
> > I will apply the new suggested patch, reverting previous patch, and test overnight and update tomorrow.
> 
> Did this solve your problem?  If not, would you mind sharing a repro?
> 

https://www.mail-archive.com/netdev@vger.kernel.org/msg72736.html
