From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: [PATCH] sungem: PHY updates & pause fixes
Date: Thu, 4 Jan 2007 21:57:42 +0100
Message-ID: <5cac192f0701041257i61e85239y638637a615d421fd@mail.gmail.com>
References: <1167802802.6165.129.camel@localhost.localdomain>
	 <20070103.185521.64808473.davem@davemloft.net>
	 <5cac192f0701041206x421824e9oedcd6a8e5c814f8b@mail.gmail.com>
	 <20070104.122716.58455250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:61197 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030211AbXADU5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 15:57:44 -0500
Received: by wr-out-0506.google.com with SMTP id 68so957090wri
        for <netdev@vger.kernel.org>; Thu, 04 Jan 2007 12:57:43 -0800 (PST)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20070104.122716.58455250.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/4/07, David Miller <davem@davemloft.net> wrote:
> From: "Eric Lemoine" <eric.lemoine@gmail.com>
> Date: Thu, 4 Jan 2007 21:06:48 +0100
>
> > On 1/4/07, David Miller <davem@davemloft.net> wrote:
> > > I've applied that patch, thanks.
> >
> > David, I suppose you've applied the locking patch as well...
>
> No, not yet.
>
> Your locking patches are definitely 2.6.21 material, but
> Ben's changes fix PAUSE handling bugs so I want to
> put his patch into 2.6.20
>
> I'll put your locking bits into 2.6.21, don't worry :-)

I'm relieved now :-)

I was asking because Ben said his patch applied on top of mine.


-- 
Eric
