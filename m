From: Kevin Wilson <wkevils@gmail.com>
Subject: Re: net next git tree cloning - a problem
Date: Thu, 15 Mar 2012 22:36:47 +0200
Message-ID: <CAGXs5wUCNvFNNxy=toY7KW9tA+HNq4RcA2bWxqessPHOZmkeDQ@mail.gmail.com>
References: <CAGXs5wVqqD=v3OruOPMewmUdEyMtGEV3RHwsNih+yBeFr5-fvQ@mail.gmail.com>
	<1331842912.23722.6.camel@frustration.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:41382 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161450Ab2COUgs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 16:36:48 -0400
Received: by vcqp1 with SMTP id p1so3561275vcq.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 13:36:47 -0700 (PDT)
In-Reply-To: <1331842912.23722.6.camel@frustration.ornl.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI,
Yes , this is indeed so
thnk!

kw

On Thu, Mar 15, 2012 at 10:21 PM, David Dillow <dave@thedillows.org> wr=
ote:
> On Thu, 2012-03-15 at 21:51 +0200, Kevin Wilson wrote:
>> git log | more
>>
>> shows:
>>
>> commit cdf485be3a63d1f34293740fb726088c6840ceea
>> Author: John Fastabend <john.r.fastabend@intel.com>
>> Date: =A0 Sat Feb 11 06:26:00 2012 +0000
>
> git shows the date the patch was written by default, not the date it =
was
> committed to the tree. Use 'git log --pretty=3Dfuller' and you'll see=
 the
> commit date was much more recent.
>
