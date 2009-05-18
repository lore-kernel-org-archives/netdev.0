From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 13:27:08 +0100
Message-ID: <298f5c050905180527y52796deu191c16adef9548d0@mail.gmail.com>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>
	 <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
	 <20090515111227.7fc758cd@nehalam>
	 <298f5c050905180301s1c4ffdb2p61a155668eb39bd2@mail.gmail.com>
	 <20090518104559.GA11162@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:52529 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbZERM1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 08:27:08 -0400
Received: by fxm2 with SMTP id 2so3200523fxm.37
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 05:27:09 -0700 (PDT)
In-Reply-To: <20090518104559.GA11162@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Looks great! But, since HFSC uses rates directly (without rate tables)

This matter about the use of rate tables is not very familiar to me.
In fact I keep wondering a lot of things about what kernel does with
packets. Is there any documentation explaining how queue disciplines
work and how it interacts with netfilter and tc_core? What about
packets dispatching?

Thanks
  Antonio Almeida
