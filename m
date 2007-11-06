From: jamal <hadi@cyberus.ca>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Tue, 06 Nov 2007 09:43:46 -0500
Message-ID: <1194360226.4444.39.camel@localhost>
References: <20071105091231.GA1933@ff.dom.local>
	 <1194267561.2987.141.camel@localhost.localdomain>
	 <20071105135246.GB1933@ff.dom.local> <1194271589.4438.113.camel@localhost>
	 <1194283888.2987.186.camel@localhost.localdomain> <472F85F0.8060205@o2.pl>
	 <1194301667.4430.28.camel@localhost> <472FAF29.7050704@o2.pl>
	 <1194336542.3305.33.camel@rad.rendec.ines.ro>
	 <1194356071.4444.23.camel@localhost>  <20071106142558.GC1666@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:37385 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbXKFOn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 09:43:57 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2424731wah
        for <netdev@vger.kernel.org>; Tue, 06 Nov 2007 06:43:56 -0800 (PST)
In-Reply-To: <20071106142558.GC1666@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-06-11 at 15:25 +0100, Jarek Poplawski wrote:

> Yes, it saves one htonl() on the slow path!

Would it feel better to say grew down exponentially from version 1 to
3? ;->

> > Please give yourself a little pat on the back for me.
> 
> Wait a minute! Don't forget to take a picture or something!

He needs the other arm for balance;-> so unless someone else takes the
photo, i would say that should he be successful taking the photo, that
achievement itself needs a double-self-pat-on-the-back (which i am going
to say if he can also take a photo of needs to go on some records book)

cheers,
jamal

