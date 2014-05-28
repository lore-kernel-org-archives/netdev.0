From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH v1 for-next 0/3] IB: Use GFP_NOIO calls in IPoIB connected
 mode TX path
Date: Wed, 28 May 2014 16:57:31 +0300
Message-ID: <CAJZOPZ+OPc9VWqwyE_erZfQbQ0VV-0yr7NiCyJOH5LUM_xyx2g@mail.gmail.com>
References: <1399810512-30774-1-git-send-email-ogerlitz@mellanox.com>
	<alpine.LNX.2.00.1405131338030.16459@pobox.suse.cz>
	<CAJZOPZJVxF6A-3s16feqoWCb5gOLTjyUmB3F+st1+1QWp+bJnQ@mail.gmail.com>
	<CAL1RGDUoEFF=fR-e-fc1v0yHp8sxaidBnO_2iiAFThgZNvCcfQ@mail.gmail.com>
	<alpine.LNX.2.00.1405261251520.12047@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jiri Kosina <jkosina@suse.cz>,
	Roland Dreier <roland@purestorage.com>
To: Roland Dreier <roland@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1405261251520.12047@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 26, 2014 at 1:52 PM, Jiri Kosina <jkosina@suse.cz> wrote:
> On Mon, 19 May 2014, Roland Dreier wrote:
>
>> > Roland, we're soon on -rc6 and there's no reason for this to miss
>>> 3.16, could you please comment whether you want it to go through your
>>> tree or net-next?

>> I will pick it up.

> Thanks Roland.
> Sorry for being a bit persistent, but another week has passed, -rc7 is out
> and I still don't see it in your tree. Could you please clarify what is
> the destiny of this patchset?

Roland, so M2 starts worrying, you have picked into your for-next
branch yesterday the other pending series, but not this one, so?

Or.
