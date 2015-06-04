From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net-next 0/3] IP imposition of per-nh MPLS encap
Date: Thu, 04 Jun 2015 17:12:57 +0200
Message-ID: <55706AF9.4090909@6wind.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>	<87h9qqx9n5.fsf@x220.int.ebiederm.org> <556E18BE.8060505@brocade.com>	<87d21dolyt.fsf@x220.int.ebiederm.org> <556E2B0B.4040100@brocade.com> <87a8whhg4x.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>,
	Thomas Graf <tgraf@suug.ch>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36586 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbbFDPNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 11:13:00 -0400
Received: by wibdq8 with SMTP id dq8so128261749wib.1
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 08:12:59 -0700 (PDT)
In-Reply-To: <87a8whhg4x.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/06/2015 00:58, Eric W. Biederman a =C3=A9crit :
[snip]
> On the drawing board is getting cross namespace routes so with a litt=
le
> luck I will only need loopback devices in most of my network namespac=
es
> when the dust settles.
+1

I've start to look at this, but I didn't have enough time right now. Bu=
t this
feature will be a good optimization from a scalability and memory consu=
mption
point of view.
