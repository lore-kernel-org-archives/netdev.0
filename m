From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 2/5] [SCTP]: "list_for_each()" -> "list_for_each_entry()"
 where appropriate.
Date: Thu, 10 Apr 2008 15:55:53 -0400
Message-ID: <47FE70C9.3070009@hp.com>
References: <1207856394-19321-1-git-send-email-vladislav.yasevich@hp.com> <1207856394-19321-3-git-send-email-vladislav.yasevich@hp.com> <alpine.LFD.1.00.0804101545570.24254@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: "Robert P. J. Day" <rpjday@crashcourse.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:28251 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754159AbYDJT4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 15:56:04 -0400
In-Reply-To: <alpine.LFD.1.00.0804101545570.24254@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert P. J. Day wrote:
>   actually, if i remember correctly, davem rejected that change as
> being too disruptive at the moment, no?
> 
> rday
> --
> 
> ========================================================================
> Robert P. J. Day
> Linux Consulting, Training and Annoying Kernel Pedantry:
>     Have classroom, will lecture.
> 
> http://crashcourse.ca                          Waterloo, Ontario, CANADA
> ========================================================================
> 

this is for 2.6.26, which should be fine.  it was too disruptive for net.26.

-vlad
