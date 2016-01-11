From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v6 0/7] openvswitch: NAT support.
Date: Mon, 11 Jan 2016 19:50:33 +0100
Message-ID: <20160111185033.GA15660@salvia>
References: <1452277800-46541-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org, David Miller <davem@davemloft.net>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452277800-46541-1-git-send-email-jarno@ovn.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jarno,

On Fri, Jan 08, 2016 at 10:29:53AM -0800, Jarno Rajahalme wrote:
> This series adds NAT support to openvswitch kernel module.  A few
> changes are needed to the netfilter code to facilitate this (patches
> 1-2/8).  Patches 3-6 make the openvswitch kernel module ready for the
> patch 7 that adds the NAT support by calling into netfilter NAT code
> from the openvswitch conntrack action.

I received this batch just a bit later by when I already submitted my
last netfilter batch to David.

I can integrate this into the nf-next tree once the David re-opens his
merge window.

@David, let me know if you prefer an alternate path.

Thanks.
