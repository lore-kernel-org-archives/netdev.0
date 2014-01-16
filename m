From: Stuart Kendrick <stuart.kendrick.sea@gmail.com>
Subject: Re: unable to send TCP SYNs from ports below 1024
Date: Thu, 16 Jan 2014 05:37:56 -0800
Message-ID: <CAACXELk+KNBSYZNF5KrqBvAFcxxxKZoV95y8xiPyW+rmRFsZWg@mail.gmail.com>
References: <CAACXELm1Yfv+=oC-N+nnR7apHc+gtZSVpqSbX2Rtkiq6-Y1QtA@mail.gmail.com>
	<20140115114715.GC19945@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Stuart Kendrick <stuart.kendrick.sea@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:36815 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbaAPNh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 08:37:58 -0500
Received: by mail-lb0-f170.google.com with SMTP id u14so1940389lbd.1
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 05:37:56 -0800 (PST)
In-Reply-To: <20140115114715.GC19945@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I hadn't thought of the switch.  And inserting an in-line tap on
either side of the switch ... shows that it is dropping these frames.
Thanx for the suggestion,

--sk
