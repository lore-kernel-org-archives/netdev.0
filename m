From: jamal <hadi@cyberus.ca>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Fri, 07 Mar 2008 09:58:41 -0500
Message-ID: <1204901921.4431.108.camel@localhost>
References: <20080225113930.GA4733@ff.dom.local>
	 <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local>
	 <20080306135625.M25627@visp.net.lb> <1204813634.4440.59.camel@localhost>
	 <20080306143910.M91001@visp.net.lb> <20080306202551.GB2876@ami.dom.local>
	 <1204837000.4457.108.camel@localhost> <20080306221253.GD2876@ami.dom.local>
	 <20080306233151.M43262@visp.net.lb> <20080307093150.GA4203@ff.dom.local>
	 <20080307101504.M78767@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:18200 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964AbYCGO6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 09:58:47 -0500
Received: by wx-out-0506.google.com with SMTP id h31so710113wxd.4
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2008 06:58:46 -0800 (PST)
In-Reply-To: <20080307101504.M78767@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-03 at 12:19 +0200, Denys Fedoryshchenko wrote:
> Ok, i will proceed and will try all required options after few hours (need to 
> go another city, work).
> I will try to set max as possible debug options.

This is embarassing on my part - all this time i claimed i couldnt
reproduce it was because i didnt have DEPLOCK debuging on. I apologize.
I am only have time to rebuild the kernel but not test it. In any case,
Denys even if i do reproduce it this is a false positive i.e it is just
noise in my opinion and you can safely ignore it (refer to my emails to
Jarek). 
Perhaps we should invest the time trying to reproduce the other issues
you have instead.

cheers,
jamal

