From: "Igor Podlesny" <for.poige+linux@gmail.com>
Subject: Re: re-formated /Re: Hi!Couldn't you take a look at kernel stack's trace? (ip_route_input+0x91a/0xcc9)/
Date: Thu, 12 Jun 2008 20:24:05 +0800
Message-ID: <43d009740806120524g78d066d2x95640fc8e01be625@mail.gmail.com>
References: <43d009740806100736y343bad9bt3a8b365292cced49@mail.gmail.com>
	 <4851116A.6040805@trash.net>
Reply-To: for.poige+linux@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:40309 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756982AbYFLMYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 08:24:06 -0400
Received: by wx-out-0506.google.com with SMTP id h29so1408278wxd.4
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 05:24:05 -0700 (PDT)
In-Reply-To: <4851116A.6040805@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/6/12 Patrick McHardy <kaber@trash.net>:
> > Igor Podlesny wrote:
>> >>
>> >>  Pid: 8, comm: sirq-net-rx/0 Not tainted (2.6.25.4-rt4aa-gcc43 #1)
                                            ^^^^^^^^^^^^^^^^^^^^^^^^^

	(2.6.25.4-rt4aa-gcc43)
	
	-RT is real-time: http://rt.wiki.kernel.org/index.php/Main_Page

>> >>  EIP: 0060:[<c0313d75>] EFLAGS: 00010202 CPU: 0
[...]
> > Whats sirq-net-rx? Doesn't seem to be present in the mainline tree.
> >

-- 
End of message. Next message?
