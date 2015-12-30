From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Q: bad routing table cache entries
Date: Wed, 30 Dec 2015 09:17:42 -0500
Message-ID: <1451485062.8255.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5682665A.7090102@list.ru> <20151229152208.GA22423@oracle.com>
	 <5683D131.4090703@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33888 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbbL3ORo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 09:17:44 -0500
Received: by mail-pf0-f172.google.com with SMTP id e65so89997159pfe.1
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 06:17:44 -0800 (PST)
In-Reply-To: <5683D131.4090703@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-30 at 15:42 +0300, Stas Sergeev wrote:
> 29.12.2015 18:22, Sowmini Varadhan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > Do you have admin control over the ubuntu router?
> > If yes, you might want to check the shared_media [#] setting=20
> > on that router for the interfaces with overlapping subnets.
> > (it is on by default, I would try turning it off).
> That didn't help, problem re-appears.
> Thanks anyway, looks like I am going to disable accept_redirects then=
=2E
> It seems buggy and obviously no one cares.

Obviously some people take vacations at this period of the year, and do
stay away from netdev traffic.
