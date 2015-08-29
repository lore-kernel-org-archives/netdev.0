From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Fix conntrack compilation
 without mark.
Date: Fri, 28 Aug 2015 22:24:15 -0700 (PDT)
Message-ID: <20150828.222415.229963880853834489.davem@davemloft.net>
References: <1440814931-29059-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	simon.horman@netronome.com
To: joestringer@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440814931-29059-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joestringer@nicira.com>
Date: Fri, 28 Aug 2015 19:22:11 -0700

> Fix build with !CONFIG_NF_CONNTRACK_MARK && CONFIG_OPENVSWITCH_CONNTRACK
> 
> Fixes: 182e304 ("openvswitch: Allow matching on conntrack mark")
> Reported-by: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Applied, thanks.
