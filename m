From: =?ISO-8859-1?Q?Adrian-Ken_R=FCegsegger?= <rueegsegger@swiss-it.ch>
Subject: Re: [danmcd@sun.com: [Ipsec-tools-devel] SHA-2 and RFC 4868]
Date: Tue, 12 May 2009 10:16:27 +0200
Message-ID: <4A09305B.5040304@swiss-it.ch>
References: <20090508180811.GA15999@kebe.East.Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan McDonald <danmcd@sun.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailx.swiss-it.ch ([81.6.4.203]:58838 "EHLO mailx.swiss-it.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758147AbZELIlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2009 04:41:40 -0400
In-Reply-To: <20090508180811.GA15999@kebe.East.Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> ----- Forwarded message from Dan McDonald <danmcd@sun.com> -----
> 
> Date: Thu, 07 May 2009 15:57:39 -0400
> From: Dan McDonald <danmcd@sun.com>
> To: ipsec-tools-devel@lists.sourceforge.net
> Subject: [Ipsec-tools-devel] SHA-2 and RFC 4868
> User-Agent: Mutt/1.5.19 (2009-01-05)
> 
> Not sure if this is the most appropriate list for the topic, but I'm sure
> enough actual AH/ESP implementors hang out here.
> 
> I've noticed at least one other platform doesn't do SHA-2 per RFC 4868
> (half-sized hash truncation), and instead truncates the SHA-2 hashes to
> 96-bits like MD5 and SHA1.
> 
> Is this just me, or is there an unfixed kernel problem in other platforms'
> AH/ESP code?

This issues was discussed (but not resolved) a bit less than a year ago:

http://lkml.org/lkml/2008/6/5/141

Regards,
Adrian
