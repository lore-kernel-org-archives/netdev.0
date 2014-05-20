From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH v1 for-next 0/3] IB: Use GFP_NOIO calls in IPoIB connected
 mode TX path
Date: Mon, 19 May 2014 18:04:10 -0700
Message-ID: <CAL1RGDUoEFF=fR-e-fc1v0yHp8sxaidBnO_2iiAFThgZNvCcfQ@mail.gmail.com>
References: <1399810512-30774-1-git-send-email-ogerlitz@mellanox.com>
 <alpine.LNX.2.00.1405131338030.16459@pobox.suse.cz> <CAJZOPZJVxF6A-3s16feqoWCb5gOLTjyUmB3F+st1+1QWp+bJnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Kosina <jkosina@suse.cz>, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJZOPZJVxF6A-3s16feqoWCb5gOLTjyUmB3F+st1+1QWp+bJnQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 17, 2014 at 1:52 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> Roland, we're soon on -rc6 and there's no reason for this to miss
> 3.16, could you please comment whether you want it to go through your
> tree or net-next?

I will pick it up.
