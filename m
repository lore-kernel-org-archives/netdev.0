From: Bill Sommerfeld <wsommerfeld@google.com>
Subject: Re: [PATCH] Make INET_LHTABLE_SIZE a compile-time tunable
Date: Mon, 31 Jan 2011 18:04:30 -0800
Message-ID: <AANLkTinSF1p7=n+KKZzCJX+Q8OcxgA=R0g2QrMF1eR0a@mail.gmail.com>
References: <1295041688-16550-1-git-send-email-wsommerfeld@google.com>
	<AANLkTi=5ncH6aRY5ifA0TONB7L5RDdHkriMY1p=aDxs6@mail.gmail.com>
	<20110131.140503.179938794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:23284 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092Ab1BACEk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 21:04:40 -0500
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p1124dcC024707
	for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 18:04:39 -0800
Received: from yib17 (yib17.prod.google.com [10.243.65.81])
	by kpbe14.cbf.corp.google.com with ESMTP id p1124WSp029873
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 18:04:37 -0800
Received: by yib17 with SMTP id 17so2604003yib.12
        for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 18:04:31 -0800 (PST)
In-Reply-To: <20110131.140503.179938794.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 31, 2011 at 14:05, David Miller <davem@davemloft.net> wrote=
:
> From: Bill Sommerfeld <wsommerfeld@google.com>
>> I haven't seen any responses to this patch submission. =A0Can someon=
e
>> take a look? =A0Thanks.
> It should be dynamically sized. =A0Compile time configuration knobs
> generally stick.

I'll work on that.  Consider this patch withdrawn until then.
