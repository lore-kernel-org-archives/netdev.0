From: Bob Beers <bob.beers@gmail.com>
Subject: Re: wanPMC-CxT1E1
Date: Mon, 2 Nov 2009 16:35:39 -0500
Message-ID: <4f6ba3b0911021335k3054da38x56fe72ac7ea8781c@mail.gmail.com>
References: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
	 <20091026204144.GA28436@kroah.com>
	 <4f6ba3b0910271048n10ff37fek9af191b133892e1e@mail.gmail.com>
	 <m3d4454phz.fsf@intrepid.localdomain>
	 <4f6ba3b0911021241gb6d9684ga76228013e0f5f14@mail.gmail.com>
	 <20091102205911.GA23443@kroah.com>
	 <4f6ba3b0911021316v16ff7431s4dfa939743541df6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f228.google.com ([209.85.219.228]:65346 "EHLO
	mail-ew0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756692AbZKBVff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 16:35:35 -0500
Received: by ewy28 with SMTP id 28so5332079ewy.18
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 13:35:39 -0800 (PST)
In-Reply-To: <4f6ba3b0911021316v16ff7431s4dfa939743541df6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just remembered that I have another mistake in the patch that I'd
 like to confess:  I put a 'CONFIG_CXT1E1 = m" at the top
 of the staging/cxt1e1/Makefile.

I should be able to fix those things an generate another patch file,
 but my git skills are very weak, so I guess you have the options:
 fix it up by hand, or teach me a little more git, so I can submit
 a better patch.

thanks,
-- 
-Bob Beers
