From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 net-next 00/10] OVS conntrack support
Date: Thu, 27 Aug 2015 11:41:05 -0700 (PDT)
Message-ID: <20150827.114105.1709123044511786497.davem@davemloft.net>
References: <1440613913-10141-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@suug.ch,
	jpettit@nicira.com, jesse@nicira.com,
	netfilter-devel@vger.kernel.org
To: joestringer@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440613913-10141-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joestringer@nicira.com>
Date: Wed, 26 Aug 2015 11:31:43 -0700

> The goal of this series is to allow OVS to send packets through the Linux
> kernel connection tracker, and subsequently match on fields populated by
> conntrack. This functionality is enabled through a new
> CONFIG_OPENVSWITCH_CONNTRACK option.
> 
> This version addresses the feedback from v5, primarily checking the behaviour
> is correct with different configurations such as disabling
> CONFIG_OPENVSWITCH_CONNTRACK or disabling individual conntrack features like
> connlabels.
> 
> The branch below has been updated with the corresponding userspace pieces:
> https://github.com/joestringer/ovs dev/ct_20150818

Series applied, thanks.
