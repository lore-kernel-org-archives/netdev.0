From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: pull request: wireless-next 2014-06-06
Date: Fri, 6 Jun 2014 21:39:02 +0200
Message-ID: <CACna6rzZMpNWrFGjVypUM5bEbiDJoYx-a0i+r9J97QeDFUXV9Q@mail.gmail.com>
References: <20140606160557.GA3208@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:59657 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbaFFTjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 15:39:03 -0400
In-Reply-To: <20140606160557.GA3208@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

On 6 June 2014 18:05, John W. Linville <linville@tuxdriver.com> wrote:
> Please accept this batch of fixes intended for the 3.16 stream.

I'll be very thankful if you include my fix in the next pull request:
[FIX for 3.16][PATCH] b43: disable 5 GHz on G-PHY
It fixes a regression I unfortunately introduced and that is present
in net-next.git.
