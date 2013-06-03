From: Roland Dreier <roland@kernel.org>
Subject: Re: BQL-related tg3 transmit timeout on 5720 / Dell R720
Date: Mon, 3 Jun 2013 09:40:01 -0700
Message-ID: <CAG4TOxPkCR66MY1U5jA+QX72hrfYy21XPMOba6M=mz=g-eB6Ew@mail.gmail.com>
References: <CAL1RGDW=SC3E9VvQXki0Gajj0xBqwHjBWM95k00J6zn1tF1mgg@mail.gmail.com>
 <51A7638A.5030108@broadcom.com> <CAG4TOxPy1mkY68sO=SttS78evL1dkFZ4ZNUUOnKPmUjifq-92Q@mail.gmail.com>
 <51A7F413.5070702@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:39764 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab3FCQkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 12:40:22 -0400
Received: by mail-wi0-f171.google.com with SMTP id hq7so2893025wib.4
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 09:40:21 -0700 (PDT)
In-Reply-To: <51A7F413.5070702@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Could you test the attached patch on top of net-next?

Yep, that works.

Tested-by: Roland Dreier <roland@purestorage.com>

Thanks!
