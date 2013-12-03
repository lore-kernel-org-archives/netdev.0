From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 20/39] net: remove DEFINE_PCI_DEVICE_TABLE macro
Date: Mon, 2 Dec 2013 18:36:46 -0800
Message-ID: <20131202183646.459564a9@nehalam.linuxnetplumber.net>
References: <001501ceefb1$69c96820$3d5c3860$%han@samsung.com>
	<002901ceefb4$f1191e30$d34b5a90$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, 'David Miller' <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <002901ceefb4$f1191e30$d34b5a90$%han@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 03 Dec 2013 08:19:25 +0900
Jingoo Han <jg1.han@samsung.com> wrote:

> Don't use DEFINE_PCI_DEVICE_TABLE macro, because this macro
> is not preferred.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Perhaps a little more explanation why it is not preferred.
Not everyone tracks LKML or the PCI list.
