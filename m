From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Fri, 30 Mar 2012 16:45:54 -0400 (EDT)
Message-ID: <20120330.164554.2217665316338460995.davem@davemloft.net>
References: <20120228.223258.2261979237568571219.davem@davemloft.net>
	<CAB=NE6W-CYjEhbfYOv7XqXFGvdhZxRECqfAmgouaa5_j45gnOQ@mail.gmail.com>
	<CAB=NE6WPWmrTZ__JQViqhde-krBsbM5G+ZQgK0pNC+W909u_ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiong@qca.qualcomm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qca-linux-team@qualcomm.com,
	nic-devel@qualcomm.com, kgiori@qca.qualcomm.com,
	chris.snook@gmail.com, mathieu@qca.qualcomm.com,
	bryanh@quicinc.com, jespera@diku.dk, julia@diku.dk
To: rodrigue@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6WPWmrTZ__JQViqhde-krBsbM5G+ZQgK0pNC+W909u_ew@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Date: Fri, 30 Mar 2012 10:10:55 -0700

> On Wed, Mar 21, 2012 at 6:28 PM, Luis R. Rodriguez
> <rodrigue@qca.qualcomm.com> wrote:
>> On Tue, Feb 28, 2012 at 7:32 PM, David Miller <davem@davemloft.net> wrote:
>> Would it be worthwhile to consider alx upstream only for the newer
>> chipsets (regardless of the litmus test, which I do agree with on
>> technical grounds) in consideration for helping pave the way on
>> killing proprietary drivers?
 ...
> David, please us know if you think the above reason is worthy for
> consideration of alx upstream, if at least for the newer chipsets.

Submitting alx that only supports the newer chipsets is fine.
