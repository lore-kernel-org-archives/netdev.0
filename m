From: Will de Bruijn <willemb@google.com>
Subject: Re: [PATCH 2/2] net: minor update to Documentation/networking/scaling.txt
Date: Mon, 15 Aug 2011 12:11:00 -0400
Message-ID: <CA+FuTScsrN5=NLeHgyNP+TXL+_auU6p80Lb5JUaMb_o5aGGqww@mail.gmail.com>
References: <1312899648.5889.14.camel@gopher.nyc.corp.google.com>
 <4E418030.2010102@hp.com> <4E44752D.1080905@google.com> <4E4476CC.5050900@google.com>
 <4E45B810.3000501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdunlap@xenotime.net, linux-doc@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:24584 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab1HOQLd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 12:11:33 -0400
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p7FGBVHc012521
	for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 09:11:32 -0700
Received: from bkbzu17 (bkbzu17.prod.google.com [10.205.80.145])
	by hpaq3.eem.corp.google.com with ESMTP id p7FGBOZA024129
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 09:11:30 -0700
Received: by bkbzu17 with SMTP id zu17so3396126bkb.6
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 09:11:30 -0700 (PDT)
In-Reply-To: <4E45B810.3000501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'd suggest simply "share a particular level in the memory hierarchy =
(Cache,
> NUMA node, etc)" =A0and that way you get away from people asking nitp=
icky
> questions about where cache hierarchy counting starts, and at what le=
vel
> caches might be shared :)
>
> Apart from that, looks fine.

Thanks. It is already applied, so if you don't feel strongly about
this, I'll leave it as is (and take any nitpicky flak if that comes ;)
