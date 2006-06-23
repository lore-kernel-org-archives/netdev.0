From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Streamline testing of 802.11 drivers
Date: Fri, 23 Jun 2006 18:56:05 -0400
Message-ID: <43e72e890606231556o57f1590fve91a98b5adfa5379@mail.gmail.com>
References: <43e72e890606231333kd0fc534x5d08dad955d13bf5@mail.gmail.com>
	 <449C6FA5.4060300@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:51187 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1752154AbWFWW4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 18:56:06 -0400
Received: by ug-out-1314.google.com with SMTP id a2so1262973ugf
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2006 15:56:05 -0700 (PDT)
To: "Larry Finger" <Larry.Finger@lwfinger.net>
In-Reply-To: <449C6FA5.4060300@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/23/06, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> Luis R. Rodriguez wrote:
> >
> > Right now we have zome zd1211s so we'll start with that (I'll start
> > working on a port to d80211) but will try to accomodate other nodes as
> > we get more wireless cards. We will need some help too though, to
> > streamline the testing. If you have ideas or would like to contribute
> > please let me know. We can purchase wireless cards but if you already
> > have reliable confirmed wireless cards which can be used for putting
> > into the testbed let me know.
>
> I have a spare Linksys WPC54G Cardbus adapter with an early Broadcom BCM4306 chip in it. The LEDS do
> not work, but everything else is OK.

Thanks Larry -- I'm sorry for not mentioning in the original thread
but basically miniPCI and USB is what we can slap onto our nodes so
far. We'll have to figure something out for Cardbus..  I searched and
it seems there some miniPCI bcm4306. I'll see if we can come up with a
cardbus solution though as I'm sure there's gotta be some card which
don't ship in other form factors. Will get back to you on that.

  Luis
