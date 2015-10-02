From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Soft lockup issue in Linux 4.1.9
Date: Fri, 02 Oct 2015 13:59:43 -0700
Message-ID: <1443819583.32531.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443650383.13282.10.camel@daevel.fr>
	 <560D1223.3070606@googlemail.com>
	 <CANn89i+B5T4Rhs8HnrC0+f+GhLvBFfpr4BVDvhkVOveSfy9B8Q@mail.gmail.com>
	 <560D1C5A.3050508@googlemail.com>
	 <CANn89iKvTUKZTiWQYbjXLr4NvYKDgd_mKYVzZHiSqk0e0OfGxA@mail.gmail.com>
	 <alpine.DEB.2.11.1510022200130.4500@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Holger =?ISO-8859-1?Q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32915 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbbJBU7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 16:59:45 -0400
In-Reply-To: <alpine.DEB.2.11.1510022200130.4500@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-02 at 22:04 +0200, Thomas Gleixner wrote:

> What makes sure, that the timer cannot be readded while that timer
> callback is running?

What is exactly your question ?
