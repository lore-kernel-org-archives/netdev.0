From: Wenji Wu <wenji@fnal.gov>
Subject: RE: A Linux TCP SACK Question
Date: Mon, 07 Apr 2008 09:56:46 -0500
Message-ID: <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
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
Reply-To: wenji@fnal.gov
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: =?iso-8859-1?Q?'Ilpo_J=E4rvinen'?= <ilpo.jarvinen@helsinki.fi>,
	'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: 'Sangtae Ha' <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.fnal.gov ([131.225.111.11]:36098 "EHLO mailgw1.fnal.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343AbYDGPBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 11:01:48 -0400
Received: from mailav1.fnal.gov (mailav1.fnal.gov [131.225.111.18])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0JYY00IUVMSQ2R@mailgw1.fnal.gov> for netdev@vger.kernel.org;
 Mon, 07 Apr 2008 09:56:51 -0500 (CDT)
Received: from mailgw2.fnal.gov ([131.225.111.12])
 by mailav1.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2008040709565002888 for
 <netdev@vger.kernel.org>; Mon, 07 Apr 2008 09:56:50 -0500
Received: from conversion-daemon.mailgw2.fnal.gov by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0JYY00E01MU1HB@mailgw2.fnal.gov> (original mail from wenji@fnal.gov)
 for netdev@vger.kernel.org; Mon, 07 Apr 2008 09:56:51 -0500 (CDT)
In-reply-to: <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>I don't think reorderings frequently happened in your directly
>connected networking scenario. Please post your tcpdump file for
>clearing out all doubts.

https://plone3.fnal.gov/P0/WAN/Members/wenji/tcp_dump_files_sack/

Two tcpdump files: one with SACK on, the other with SACK off. The test
configures described in my previous emails.

Best,

wenji


