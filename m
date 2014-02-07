From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: linux 3.13: problems with isatap tunnel device and UFO
Date: Fri, 7 Feb 2014 23:22:27 +0100
Message-ID: <20140207222227.GC16198@order.stressinduktion.org>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de> <20140207175641.GB16198@order.stressinduktion.org> <1720760.5dnaEcLin5@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38736 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbaBGWW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 17:22:28 -0500
Content-Disposition: inline
In-Reply-To: <1720760.5dnaEcLin5@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Fri, Feb 07, 2014 at 07:17:40PM +0100, Wolfgang Walter wrote:
> Am Freitag, 7. Februar 2014, 18:56:41 schrieb Hannes Frederic Sowa:
> > Hi!
> > 
> > On Fri, Feb 07, 2014 at 06:47:07PM +0100, Wolfgang Walter wrote:
> > > with kernel 3.13 I have a problem with isatap tunnels receiving fragmented
> > > ipv6 udp packets.
> > 
> > Which was the last known version that did work?
> 
> I think 3.12 had no problems, but I'm not sure. I test this tonight.

Could you give me a bit more details on your setup, please?

I just tested a setup with UFO packets in sit tunnels and it worked
properly for me (on net).

Greetings,

  Hannes
