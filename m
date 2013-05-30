From: Roland Dreier <roland@kernel.org>
Subject: Re: BQL-related tg3 transmit timeout on 5720 / Dell R720
Date: Thu, 30 May 2013 09:19:26 -0700
Message-ID: <CAG4TOxPy1mkY68sO=SttS78evL1dkFZ4ZNUUOnKPmUjifq-92Q@mail.gmail.com>
References: <CAL1RGDW=SC3E9VvQXki0Gajj0xBqwHjBWM95k00J6zn1tF1mgg@mail.gmail.com>
 <51A7638A.5030108@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:47091 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935006Ab3E3QTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 12:19:48 -0400
Received: by mail-we0-f176.google.com with SMTP id p58so428355wes.7
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 09:19:46 -0700 (PDT)
In-Reply-To: <51A7638A.5030108@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 7:34 AM, Nithin Nayak Sujir <nsujir@broadcom.com> wrote:
> Is the 5720 a NIC or a LOM? If it's a NIC would it be possible to try it on
> a different system to see if the behaviour depends on the system at all?

This is the LOM.  On the Dell it's a daughtercard but I don't think
it's user-replaceable.

In other words, sorry, I don't think I can try it on a different system.

 - R.
