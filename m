From: jamal <hadi@cyberus.ca>
Subject: Re: xfrm_add_sa_expire return codes
Date: Mon, 26 Feb 2007 19:31:06 -0500
Message-ID: <1172536266.4847.4.camel@localhost>
References: <499d6ed30702261426r107fb555hd621418376f5c61c@mail.gmail.com>
	 <20070226.144854.102122743.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shpedoikal@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.235]:4727 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbXB0AbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 19:31:14 -0500
Received: by nz-out-0506.google.com with SMTP id s1so1417462nze
        for <netdev@vger.kernel.org>; Mon, 26 Feb 2007 16:31:10 -0800 (PST)
In-Reply-To: <20070226.144854.102122743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-26-02 at 14:48 -0800, David Miller wrote:

> Indeed, and the tabbing on the first "err = " assignment should
> be a clue that some mistake might have been added.
> 
> It looks like the code has been like that from day one, I wonder
> how Jamal tested this stuff :-)
> 

I am asking myself the same question staring at that;-> 
Let me look at the test code tommorow and get back to you. I know my
test was "passing" ;->

> I'm going to assume the intended logic, and fix it like this.
> Jamal?
> 

Looks good - thanks Dave.

cheers,
jamal

