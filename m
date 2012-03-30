From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Fri, 30 Mar 2012 13:52:34 -0700
Message-ID: <20120330205234.GD4086@tux>
References: <20120228.223258.2261979237568571219.davem@davemloft.net>
 <CAB=NE6W-CYjEhbfYOv7XqXFGvdhZxRECqfAmgouaa5_j45gnOQ@mail.gmail.com>
 <CAB=NE6WPWmrTZ__JQViqhde-krBsbM5G+ZQgK0pNC+W909u_ew@mail.gmail.com>
 <20120330.164554.2217665316338460995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xiong@qca.qualcomm.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <qca-linux-team@qualcomm.com>,
	<nic-devel@qualcomm.com>, <kgiori@qca.qualcomm.com>,
	<chris.snook@gmail.com>, <mathieu@qca.qualcomm.com>,
	<bryanh@quicinc.com>, <jespera@diku.dk>, <julia@diku.dk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:38074 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755518Ab2C3Uw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 16:52:58 -0400
Content-Disposition: inline
In-Reply-To: <20120330.164554.2217665316338460995.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 30, 2012 at 04:45:54PM -0400, David Miller wrote:
> From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
> Date: Fri, 30 Mar 2012 10:10:55 -0700
> 
> > On Wed, Mar 21, 2012 at 6:28 PM, Luis R. Rodriguez
> > <rodrigue@qca.qualcomm.com> wrote:
> >> On Tue, Feb 28, 2012 at 7:32 PM, David Miller <davem@davemloft.net> wrote:
> >> Would it be worthwhile to consider alx upstream only for the newer
> >> chipsets (regardless of the litmus test, which I do agree with on
> >> technical grounds) in consideration for helping pave the way on
> >> killing proprietary drivers?
>  ...
> > David, please us know if you think the above reason is worthy for
> > consideration of alx upstream, if at least for the newer chipsets.
> 
> Submitting alx that only supports the newer chipsets is fine.

We will work on this and resubmit, the delta for the other chipsets
can also be addressed within atl1c, in addition to working on getting
documentation out to help enable further.

  Luis
