From: Stas Sergeev <stsp@list.ru>
Subject: Re: Q: bad routing table cache entries
Date: Wed, 30 Dec 2015 15:42:25 +0300
Message-ID: <5683D131.4090703@list.ru>
References: <5682665A.7090102@list.ru> <20151229152208.GA22423@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp53.i.mail.ru ([94.100.177.113]:52017 "EHLO smtp53.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754619AbbL3Mm3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2015 07:42:29 -0500
In-Reply-To: <20151229152208.GA22423@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

29.12.2015 18:22, Sowmini Varadhan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Do you have admin control over the ubuntu router?
> If yes, you might want to check the shared_media [#] setting=20
> on that router for the interfaces with overlapping subnets.
> (it is on by default, I would try turning it off).
That didn't help, problem re-appears.
Thanks anyway, looks like I am going to disable accept_redirects then.
It seems buggy and obviously no one cares.
