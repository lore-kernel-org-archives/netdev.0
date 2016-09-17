From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net] MAINTAINERS: Gary Zambrano's email is bouncing
Date: Sat, 17 Sep 2016 16:23:57 -0700
Message-ID: <1474154637.1954.10.camel@perches.com>
References: <1474151235-16558-1-git-send-email-f.fainelli@gmail.com>
         <1474152709.1954.8.camel@perches.com>
         <CAGVrzcaswHEjEvBygXbDcgUPaAmP=t9RHY8mVv4tVOgK7N9ARw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        bcm-kernel-feedback-list <bcm-kernel-feedback-list@broadcom.com>,
        =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
        Hauke Mehrtens <hauke@hauke-m.de>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0130.hostedemail.com ([216.40.44.130]:43029 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755624AbcIQXYB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 19:24:01 -0400
In-Reply-To: <CAGVrzcaswHEjEvBygXbDcgUPaAmP=t9RHY8mVv4tVOgK7N9ARw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-09-17 at 16:17 -0700, Florian Fainelli wrote:
> 2016-09-17 15:51 GMT-07:00 Joe Perches <joe@perches.com>:
[]
> > Without an actual maintainer, this should really be
> > orphan and not supported.
> I would like to hear from Michael before concluding that

No worries.

> > And the M: bcm-kernel-feedback-list@ should be L:
> The list does not accept public subscribers, so this is the correct
> entry to use.

Then M: is definitely _not_ the correct entry for this
and it should be:

L: bcm-kernel-feedback-list@broadcom.com (subscribers-only)
