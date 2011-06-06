From: Joe Perches <joe@perches.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Mon, 06 Jun 2011 09:50:22 -0700
Message-ID: <1307379022.4994.4.camel@Joe-Laptop>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
	 <20110523151336.GF21309@gospo.rdu.redhat.com>
	 <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
	 <20110524163323.GB28521@hmsreliant.think-freely.org>
	 <BANLkTinoRXmEAp0mbZdxSmMbntsE-QeRsQ@mail.gmail.com>
	 <20110525152023.GC11867@hmsreliant.think-freely.org>
	 <BANLkTin2HaYjHgGACkwvKwuY-Y_e3+r3JQ@mail.gmail.com>
	 <20110526135053.GB12617@hmsreliant.think-freely.org>
	 <BANLkTikrsr5sZ4aZ5aEmfBSvPE0mEL8g0g@mail.gmail.com>
	 <BANLkTin4VyK3boPqDQnd+Dkv6==cHww9PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Jeffrey Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2523 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544Ab1FFQuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 12:50:24 -0400
In-Reply-To: <BANLkTin4VyK3boPqDQnd+Dkv6==cHww9PA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-07 at 00:34 +0800, Am=C3=A9rico Wang wrote:
> I agree with this, IMHO this would help to organize the code better.
> And currently only tuntap and bonding are still in net/ directory.
> In any aspects, now we are mixing net/ and drivers/net/ currently,
> which could be improved.

There is a proposal to move some drivers/net content to
drivers/net/sw/

http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf

I think that'd be fine too.

I believe Jeff is going to submit patches soonish.

http://comments.gmane.org/gmane.linux.network/197232


