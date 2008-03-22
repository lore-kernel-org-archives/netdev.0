From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH-2.6.26] rndis_host: fix oops when query for OID_GEN_PHYSICAL_MEDIUM fails
Date: Sat, 22 Mar 2008 10:58:17 -0700
Message-ID: <200803221058.17370.david-b@pacbell.net>
References: <20080317213301.15070.30388.stgit@fate.lan> <200803171442.11529.david-b@pacbell.net> <20080322131437.gb7triy40sgg4o80@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp123.sbc.mail.sp1.yahoo.com ([69.147.64.96]:48675 "HELO
	smtp123.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755342AbYCVR6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 13:58:23 -0400
In-Reply-To: <20080322131437.gb7triy40sgg4o80@hayate.ip6>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 22 March 2008, Jussi Kivilinna wrote:
> Quoting David Brownell <david-b@pacbell.net>:
> 
> > ... this should be for 2.6.25 though, yes?  Since that
> > change was introduced after 2.6.24, and this would
> > otherwise cause a regression ...
> 
> Should I resend patch? It hasn't got into 2.6.25 yet. Actually, who am  
> I supposed to CC bugfix patches?

A resend couldn't hurt, with a possible RC7 nearly upon us...

The folk pushing netdev patches upstream are Jeff Garzik
and David Miller.  Presumably they're like all of us, and
sometimes need nudges like direct CCs.  :)

