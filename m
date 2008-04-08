From: Wenji Wu <wenji@fnal.gov>
Subject: Re: RE: A Linux TCP SACK Question
Date: Tue, 08 Apr 2008 10:27:14 -0500
Message-ID: <fbd3c4827acd.47fb4882@fnal.gov>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71>
 <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
 <fb8e9e4f102e.47f8ebfd@fnal.gov>
 <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
 <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
 <fbbce0572843.47fb038c@fnal.gov>
 <Pine.LNX.4.64.0804081623500.21784@wrl-59.cs.helsinki.fi>
 <fba201de4228.47fb3b26@fnal.gov>
 <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: 'Sangtae Ha' <sangtae.ha@gmail.com>,
	'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.fnal.gov ([131.225.111.12]:50263 "EHLO mailgw2.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536AbYDHPd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 11:33:57 -0400
Received: from mailav2.fnal.gov (mailav2.fnal.gov [131.225.111.20])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JZ000FEJIQBY1@mailgw2.fnal.gov> for netdev@vger.kernel.org;
 Tue, 08 Apr 2008 10:27:15 -0500 (CDT)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav2.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008040810271509026 for
 <netdev@vger.kernel.org>; Tue, 08 Apr 2008 10:27:15 -0500
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JZ000J01IOWFH@mailgw2.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Tue, 08 Apr 2008 10:27:15 -0500 (CDT)
In-reply-to: <Pine.LNX.4.64.0804081742270.21784@wrl-59.cs.helsinki.fi>
Content-language: en
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> It's a bit hard for me to believe, considering what the last weeks 
> debug 
> has revealed about internals of it. Have you checked it from the dumps 
> or 
> from the overall results, a similarity in the latter could be due to 
> other factors related to the differences in reordering detection 
> between 
> NewReno/SACK.
> 

> ...There might be some bug which causes it to get skipped under some 
> circumstances though (which I haven't yet remembered to fix). I don't 
> 
> remember too well anymore, probably some goto which caused skipping 
> most 
> of what's in there.
> 

Get back to you later, and post the tcpdump file for 2.6.25. 

wenji


