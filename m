From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: Sundance network driver (D-Link DFE-580TX) timeouts rendering
 interface unusable
Date: Fri, 16 Mar 2012 17:11:27 -0500
Message-ID: <20120316221127.GB31359@burratino>
References: <1327811546.5400.291.camel@deadeye>
 <CAHj3AVm8cjkj83QHGAqOji6t4uWFr6jAAADu7vLKyfEORk1LoA@mail.gmail.com>
 <1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1327932311.5400.429.camel@deadeye>
 <1327933736.2288.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1327934477.5400.448.camel@deadeye>
 <1327935455.2297.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1327936900.2297.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <SNT141-W2773C07AA4E8276F3E1E4496730@phx.gbl>
 <20120316220413.GA31359@burratino>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, ben@decadent.org.uk, kirjanov@gmail.com,
	netdev@vger.kernel.org, benoit.mortier@opensides.be,
	herbert@gondor.apana.org.au
To: "Mike ." <mike-bugreport@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41391 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964797Ab2CPWLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 18:11:36 -0400
Received: by iagz16 with SMTP id z16so5999009iag.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 15:11:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120316220413.GA31359@burratino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Nieder wrote:

> Thanks.  I assume current 3.3 release candidates behave the same way.
>
> Based on [2], it looks like v2.6.25-rc9~99^2~24 ([NET]: Add preemption
> point in qdisc_run, 2008-03-28) made this easier to trip.
>
> As for the next step: I'd suggest posting a summary of the symptoms,
> which kernel versions you have tested, and a link to [1] at
> http://bugzilla.kernel.org/

Here's the missing footnote[2].  Sorry for the noise.

[...]
> [1] http://thread.gmane.org/gmane.linux.network/219101
[2] http://bugs.debian.org/514833
