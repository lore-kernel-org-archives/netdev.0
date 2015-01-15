From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Thu, 15 Jan 2015 20:18:12 +0200
Message-ID: <CAJ3xEMh6r-cQhvSB0s-c8BYHER8GUiCE=7cc28AALf4c1EJ6VQ@mail.gmail.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
	<CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
	<CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
	<CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
	<CA+mtBx_6HcZh5Ys1FJFBXkZ2bWX1gP6bTcjY7gbR6RG_TOy50Q@mail.gmail.com>
	<CAJ3xEMi0biCWTNtLOJ=0HWZYjOWi6pN2bw2=EWajp6XnpoyVRw@mail.gmail.com>
	<CA+mtBx-sP6g9hXAYGfHKCPYkCtjgCFM0srueh1uhoNnC2ACr1g@mail.gmail.com>
	<CAJ3xEMhc-97+3ZDwqXzX2N+=voO4QvJ5_YXn3sp8r8E9YyqotQ@mail.gmail.com>
	<CA+mtBx9=+fGjwJCKpTW5EifmavC6VGnbuJdkc5tqzeEHz+5twA@mail.gmail.com>
	<CAJ3xEMhzxfP3Sqp=_QSQehd2j2s=Gr3B1iO2S--OcoT7VC94nQ@mail.gmail.com>
	<CA+mtBx8-w74f_f9JEfpwH9=Mjr_zaJJAYCMMdYAWdCy-51pzqg@mail.gmail.com>
	<CAJ3xEMgPb9BhvtifmTzy6bS9WDf3jUx6dnx4418KNTjGNPreHQ@mail.gmail.com>
	<CA+mtBx-AW65w7grfb7zTaDKzKQ2n_7JQuLquj1Ayopa4gdiF6Q@mail.gmail.com>
	<CAJ3xEMiLsQ=Wd=461L1Wx0jQ+zivY-Z573+90dD8d7pdUD4Skw@mail.gmail.com>
	<CA+mtBx9HMuMnsmN0rjqV9-5iK9H6b+J8OZQsmmbFHwjm+qW7bQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:57524 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810AbbAOSSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 13:18:12 -0500
Received: by mail-ob0-f170.google.com with SMTP id wp18so14939836obc.1
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 10:18:12 -0800 (PST)
In-Reply-To: <CA+mtBx9HMuMnsmN0rjqV9-5iK9H6b+J8OZQsmmbFHwjm+qW7bQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 6, 2014 at 11:28 PM, Tom Herbert <therbert@google.com> wrote:
> On Mon, Oct 6, 2014 at 1:22 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:

>> Are we going to have a session on the encapsulation/offloads design @ LPC?

> yes, I will talk about FOU and GUE implementation. You should
> abstracts in the schedule now.

Hi Tom, so that LPC discussion eventually didn't made it to happen...
I saw [1] you're planning (hopefully exiting) three parts discussion @
netdev01

I would strongly vote for his to be on the workshops/tutorials days,
i.e not limited to 45m or alike... and the 1st part you plan for an
updated reply of your LSK preso [2] which missed LPC?

[1] https://netdev01.org/news/22
[2] http://vger.kernel.org/encapsulation_offloads.pdf

>> I think a replay of your LKS presentation along with open discussion
>> on how to get there with the legacy requirements could be very
>> helpful.
