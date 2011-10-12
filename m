From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3] net-netlink: Add a new attribute to expose TOS
 values via netlink
Date: Wed, 12 Oct 2011 08:52:35 -0700
Message-ID: <20111012085235.3b78729b@nehalam.linuxnetplumber.net>
References: <20111010145206.6f7e9ee2@nehalam.linuxnetplumber.net>
	<1318382887-31824-1-git-send-email-muralira@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Muraliraja Muniraju <muralira@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318382887-31824-1-git-send-email-muralira@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Oct 2011 18:28:07 -0700
Muraliraja Muniraju <muralira@google.com> wrote:

> +/* INET_DIAG_TOS */
> +
> +struct inet_diag_tos {
> +	__u8	idiag_tos;
> +};
> +

This structure is not used.
