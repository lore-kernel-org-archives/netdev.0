From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v7 08/33] net: nl80211 - make rdev_add_virtual_intf take
 name_assign_type
Date: Mon, 21 Jul 2014 11:40:10 +0200
Message-ID: <1405935610.32255.5.camel@jlt4.sipsolutions.net>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
	 <1404980258-30853-9-git-send-email-teg@jklm.no>
	 (sfid-20140710_101817_648059_1F1D29C5)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>,
	John Linville <linville@tuxdriver.com>
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-9-git-send-email-teg@jklm.no> (sfid-20140710_101817_648059_1F1D29C5)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-07-10 at 10:17 +0200, Tom Gundersen wrote:
> Pass the value down and set it at the same place the name itself is set.

Is this going to be applied as part of one bigger series?

johannes
