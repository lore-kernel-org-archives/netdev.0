From: Guillaume Leclanche <guillaume@leclanche.net>
Subject: Re: Need a special way tune TCP IPv6->IPv4 fallback timeout
Date: Thu, 24 Mar 2011 18:05:35 +0100
Message-ID: <AANLkTinb_4N_S7LG8MjT0YTAjVSkEyViv+Y-_ZN2SemC@mail.gmail.com>
References: <AANLkTikP7AFMnQ4BdnE2272zNupv_ysb3BDWTqy=9s34@mail.gmail.com> <20110324095702.6f6bade0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52807 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933899Ab1CXRFz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 13:05:55 -0400
Received: by iyb26 with SMTP id 26so155870iyb.19
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2011 10:05:55 -0700 (PDT)
In-Reply-To: <20110324095702.6f6bade0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/3/24 Stephen Hemminger <shemminger@vyatta.com>:
> The best way is to try both at the same time. This trick is known
> as "Happy Eyeballs"
>
> =A0http://tools.ietf.org/html/draft-wing-v6ops-happy-eyeballs-ipv6-01

Happy eyeballs implementation would be royal, I thought my proposal
would be easier to implement as a first step. I'm very likely to be
wrong though :) Well, if anybody is working currently on Happy
Eyeballs implementations in the TCP stack, it's great !

Guillaume
