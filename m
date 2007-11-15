From: "Jon Nelson" <jnelson@jamponi.net>
Subject: Re: tg3: strange errors and non-working-ness
Date: Thu, 15 Nov 2007 13:17:10 -0600
Message-ID: <cccedfc60711151117v70b285fbl79bbc92ced176d54@mail.gmail.com>
References: <20071115094728.GB2366@ff.dom.local> <1195154603.6360.9.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:51172 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758061AbXKOTRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 14:17:13 -0500
Received: by nf-out-0910.google.com with SMTP id g13so582676nfb
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2007 11:17:10 -0800 (PST)
In-Reply-To: <1195154603.6360.9.camel@dell>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/15/07, Michael Chan <mchan@broadcom.com> wrote:
> On Thu, 2007-11-15 at 10:47 +0100, Jarek Poplawski wrote:
> > On 13-11-2007 19:57, Jon Nelson wrote:
> > > The best info I've got is this:
>
> It looks like the card is being reset periodically.  Every time the card
> gets reset, you'll see those PM messages in the version of the driver
> you're using.  Do you see NETDEV WATCHDOG message as well in the dmesg
> log?

Is this what you mean? I pulled this from the quoted text:

Nov 10 22:45:52 frank kernel: NETDEV WATCHDOG: eth0: transmit timed out



-- 
Jon
