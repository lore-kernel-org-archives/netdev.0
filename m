From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH v3 net-next 3/4] ixgbe: Add support for ndo_ll_poll
Date: Tue, 21 May 2013 13:41:27 +0300
Message-ID: <CAJZOPZKwVW1Qot9e+A47XCJ_jdv2LSLcaDnC+gMWXYj8-DSkeg@mail.gmail.com>
References: <1369120003.25971.2.camel@lb-tlvb-eilong.il.broadcom.com>
	<20130521.001444.1361294042663568537.davem@davemloft.net>
	<CAJZOPZJTA9A8T4R8MtRCeqcYj3XJWFCXF+ojmEqza5TMj-6G+w@mail.gmail.com>
	<20130521.013912.96249995742935192.davem@davemloft.net>
	<CAJZOPZJD5QpkmkJF9qpWV3Q28aioLw5CuT5X4URxDC4eSby3nQ@mail.gmail.com>
	<519B4C0D.3040602@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, eilong@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	andi@firstfloor.org, hpa@zytor.com, eliezer@tamir.org.il
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <519B4C0D.3040602@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 21, 2013 at 1:27 PM, Eliezer Tamir
<eliezer.tamir@linux.intel.com> wrote:
> On 21/05/2013 11:43, Or Gerlitz wrote:

>> Maybe if we bake it on this list little further we can see how to get
>> away from that, or what's the most non ugly way for that?

> I'm all for proper review and fixing any issues before forcing "ugliness"
> and "black magic" on unsuspecting users.
>
> Having said that, you failed to mention that your company sells userspace
> stack replacements.

ditto for your firm, heard on DPDK? but your comment is irrelevant, I
only raised the idea that if we bake this little further we might find
a solution which avoids this nasty corner, not more but not less.

[...]

> Why don't you try it out and tell us what you find.

sure, we are looking on that on the driver level, my comment was more general
