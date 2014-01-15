From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: unable to send TCP SYNs from ports below 1024
Date: Wed, 15 Jan 2014 12:47:15 +0100
Message-ID: <20140115114715.GC19945@order.stressinduktion.org>
References: <CAACXELm1Yfv+=oC-N+nnR7apHc+gtZSVpqSbX2Rtkiq6-Y1QtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stuart Kendrick <stuart.kendrick.sea@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38969 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbaAOLrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 06:47:16 -0500
Content-Disposition: inline
In-Reply-To: <CAACXELm1Yfv+=oC-N+nnR7apHc+gtZSVpqSbX2Rtkiq6-Y1QtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 05:37:03PM -0800, Stuart Kendrick wrote:
> VALIDATION
> I verify the problem by using netcat plus two instances of tcpdump,
> one running on the box itself, the other running on a second box
> plugged into a SPAN port on the local Ethernet switch

This sounds strange. Could you try to skip the switch and plug the
boxes together directly. Maybe a switch policy? They can filter such
things nowaday.

Greetings,

  Hannes
