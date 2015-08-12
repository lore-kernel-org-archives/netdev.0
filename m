From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: Panic with demuxed ipv4 multicast udp sockets on 4.0.4
Date: Wed, 12 Aug 2015 09:13:04 -0700
Message-ID: <CALCkm3cqbST9ZDmnw4gnGyTFM2KZrPPd3+D4UxtP73yN8oMOJw@mail.gmail.com>
References: <2ddbe291fff643899849eb068ef219e0@svr-chch-ex1.atlnz.lc>
 <1438234969.20182.124.camel@edumazet-glaptop2.roam.corp.google.com>
 <1438235159.20182.125.camel@edumazet-glaptop2.roam.corp.google.com>
 <0dd213ace919410da723ac93892d1f4d@svr-chch-ex1.atlnz.lc> <1438337866.2748.5.camel@edumazet-glaptop2.roam.corp.google.com>
 <1438341449.2748.9.camel@edumazet-glaptop2.roam.corp.google.com> <0054031415584f58aeba627a5ca5aefc@svr-chch-ex1.atlnz.lc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gregory Hoggarth <Gregory.Hoggarth@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:36808 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbbHLQNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 12:13:24 -0400
Received: by qgdd90 with SMTP id d90so13602044qgd.3
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 09:13:23 -0700 (PDT)
In-Reply-To: <0054031415584f58aeba627a5ca5aefc@svr-chch-ex1.atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Gregory,

On Sun, Aug 2, 2015 at 2:28 PM, Gregory Hoggarth
<Gregory.Hoggarth@alliedtelesis.co.nz> wrote:
> I will apply the new suggested patch, reverting previous patch, and test overnight and update tomorrow.

Did this solve your problem?  If not, would you mind sharing a repro?

-- 
Alex Gartrell <agartrell@fb.com>
