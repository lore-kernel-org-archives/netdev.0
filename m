From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH 0/1] [DCCP]: Tidy up code slightly
Date: Mon, 28 Aug 2006 16:58:01 +1200
Message-ID: <5640c7e00608272158w329f2504x20eda1d3a653e460@mail.gmail.com>
References: <200608281634.51216.ian.mcdonald@jandi.co.nz>
	 <20060827.214747.116351909.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: arnaldo.melo@gmail.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-f131.google.com ([64.233.184.131]:26102 "EHLO
	wr-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1750915AbWH1E6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 00:58:01 -0400
Received: by wr-out-f131.google.com with SMTP id 10so108926wrs
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 21:58:01 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060827.214747.116351909.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/28/06, David Miller <davem@davemloft.net> wrote:
> From: Ian McDonald <ian.mcdonald@jandi.co.nz>
> Date: Mon, 28 Aug 2006 16:34:50 +1200
>
> > Arnaldo has pointed this one out to me in latest series of
> > patches. Can this go into 2.6.18 please?
>
> It's not a bug fix, so we'll defer it to 2.6.19

I guess that's true unless we change the structure which would make it
a bug fix but I'm happy for this to be in 2.6.19 since that hasn't
happened.

Ian
