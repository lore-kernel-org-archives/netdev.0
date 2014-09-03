From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [ipsec-next v4 0/2] xfrm: scalability enhancements for policy database
Date: Wed, 3 Sep 2014 14:53:52 +0200
Message-ID: <CADdy8HrfRyPxsx+RxBCogYMSY6Ah8_CyOM+UKWopKVhNY6twYQ@mail.gmail.com>
References: <20140829095431.GF6390@secunet.com>
	<1409321765-2012-1-git-send-email-christophe.gouault@6wind.com>
	<20140903115913.GH6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:35542 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932773AbaICMxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 08:53:53 -0400
Received: by mail-ie0-f169.google.com with SMTP id tr6so9565566ieb.14
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 05:53:52 -0700 (PDT)
In-Reply-To: <20140903115913.GH6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-09-03 13:59 GMT+02:00 Steffen Klassert <steffen.klassert@secunet.com>:
> On Fri, Aug 29, 2014 at 04:16:03PM +0200, Christophe Gouault wrote:
>> This patchset enables to hash more policies than just non-prefixed
>> ones: hash policies whose prefix lengths are greater or equal to
>> configurable thresholds.

> Looks good. All applied to ipsec-next, thanks a lot Christophe!

You're welcome.
Thanks for reviewing.

Christophe
