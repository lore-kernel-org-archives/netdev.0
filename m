From: jamal <hadi@cyberus.ca>
Subject: Re: is CONFIG_NET_CLS_ACT always set ?
Date: Mon, 23 Apr 2007 18:59:50 -0400
Message-ID: <1177369190.4096.13.camel@localhost>
References: <97949e3e0704231419o21062b6cl5b8cf38e1b412b05@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:34093 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754465AbXDWW7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 18:59:54 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1969931wxd
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 15:59:54 -0700 (PDT)
In-Reply-To: <97949e3e0704231419o21062b6cl5b8cf38e1b412b05@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-23-04 at 14:19 -0700, Laurent Chavey wrote:
> if CONFIG_NET_CLS_ACT is not defined, then is the
> code below correct ?

The simple answer is yes; 
Is something not working for you?

It is hard to read your question my good friend because it comes out
like a trick question;-> 
It is more useful to say:
 "I think this code is broken because ...."
And even more useful if you add:
"I have run the following testcases to illustrate blah ..."
Then if something is broken, and you want to be popular, you say:
"netdevers, heres the fix"

Anyways, what is the problem?

cheers,
jamal

