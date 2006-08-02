From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: means to artificially alter the bandwidth of a system
Date: Thu, 3 Aug 2006 08:28:15 +1200
Message-ID: <5640c7e00608021328s4c9fc25axdd403fa37b24690b@mail.gmail.com>
References: <3420082f0608021104u1f914d44rfbc672aff104924b@mail.gmail.com>
	 <20060802201051.GA3790@c3po.0xdef.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-f131.google.com ([64.233.182.131]:21903 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S932225AbWHBU2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 16:28:16 -0400
Received: by nf-out-f131.google.com with SMTP id k65so49623nfa
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2006 13:28:15 -0700 (PDT)
To: "Hagen Paul Pfeifer" <hagen@jauu.net>, netdev@vger.kernel.org
In-Reply-To: <20060802201051.GA3790@c3po.0xdef.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >Hi,
> >
> >For research purposes we are considering to develop a program to alter
> >the bandwidth of a system via the software, so instance: a machine has
> >100 MB/s and we change it to 1MB/s.
> >
> >Does something like this already exist? Or is there a way to do this
> >without creating a program/kernel module
>
> Of course: see http://linux-net.osdl.org/index.php/Iproute2 (especially tc)
>
> >Any help will be highly appreciated!
> >
> >Irfan Habib
>
> HGN
>
You may also want to look at Netem
http://linux-net.osdl.org/index.php/Netem if you want to play with
delay, loss as well. The examples there are good but I can send
scripts for you as well if you wish.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
