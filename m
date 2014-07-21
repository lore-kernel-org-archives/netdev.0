From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v7 08/33] net: nl80211 - make rdev_add_virtual_intf take name_assign_type
Date: Mon, 21 Jul 2014 19:03:04 +0200
Message-ID: <CAG-2HqVhQKQXO-7AHa2y+YfEPco2z1-QvyzoGOThADoLVxVVFg@mail.gmail.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
 <1404980258-30853-9-git-send-email-teg@jklm.no> <1405935610.32255.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>,
	John Linville <linville@tuxdriver.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405935610.32255.5.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johannes,

On Mon, Jul 21, 2014 at 11:40 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Thu, 2014-07-10 at 10:17 +0200, Tom Gundersen wrote:
>> Pass the value down and set it at the same place the name itself is set.
>
> Is this going to be applied as part of one bigger series?

This patch is superceded by "[PATCH net-next v9 2/9] net: nl80211 -
make rdev_add_virtual_intf take name_assign_type", which indeed is
part of a bigger series.

However, if you and David prefer to take it through your tree, let me
know and I'll split it out from the series and resubmit it to you
independently.

Cheers,

Tom
