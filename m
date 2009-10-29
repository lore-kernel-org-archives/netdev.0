From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: WAN device configuration, again...
Date: Thu, 29 Oct 2009 15:48:02 +0100
Message-ID: <m3r5sm5k9p.fsf@intrepid.localdomain>
References: <m3d447hcks.fsf@intrepid.localdomain>
	<1256745788.3850.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:54332 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754149AbZJ2Or7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 10:47:59 -0400
In-Reply-To: <1256745788.3850.31.camel@localhost.localdomain> (Dan Williams's
	message of "Wed, 28 Oct 2009 09:03:08 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dcbw@redhat.com> writes:

>> I think of something:
>> - using netlink or similar interface
>
> If you're doing a new config interface, I'd suggest netlink like the
> wireless guys did to replace WEXT with cfg80211.  Using netlink makes
> your interface easily available from programs/libraries without having
> to screenscrape anything.  If you want some advice on netlink API stuff,
> ask Johannes Berg.

Thanks for your mail. It seems I'll do it this way.
-- 
Krzysztof Halasa
