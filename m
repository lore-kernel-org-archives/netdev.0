From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: Fwd: TCP fragmentation broken in 3.6-rc ?
Date: Tue, 21 Aug 2012 13:56:47 +0200
Message-ID: <CAF6-1L4-45gx=YdhdyFh7FDO1ifxunT_-RQcLfT9-3Q29KeTqA@mail.gmail.com>
References: <CAF6-1L6xy1rRd321ZMzrLG6xHMdO0+sdjbtznUOsMzfYyU1SEg@mail.gmail.com>
	<CAF6-1L5bnhHfXide-=+4WmskR6xGLg4q+RWHebH+GiX7P-RX+Q@mail.gmail.com>
	<1345475670.5158.322.camel@edumazet-glaptop>
	<CAF6-1L7R_N1JkubzLwbv9eVX0F+QTtB5SXaRnXU1vBnb_avSMg@mail.gmail.com>
	<1345478571.5158.323.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:32771 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653Ab2HUL4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 07:56:48 -0400
Received: by vcbfk26 with SMTP id fk26so6008138vcb.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 04:56:47 -0700 (PDT)
In-Reply-To: <1345478571.5158.323.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Any chance you could post a tcpdump demonstrating the problem ?
> (including the tcp session plus icmp messages)

Here it is :

http://ge.tt/api/1/files/76YVbLM/0/blob?download


Cheers,

    Sylvain
