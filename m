From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] openvswitch: Rename LABEL->LABELS
Date: Mon, 05 Oct 2015 06:34:56 -0700 (PDT)
Message-ID: <20151005.063456.58751091441561045.davem@davemloft.net>
References: <201510020526.yYUtAeEs%fengguang.wu@intel.com>
	<1443736837-9581-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org, jesse@nicira.com
To: joestringer@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443736837-9581-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joestringer@nicira.com>
Date: Thu,  1 Oct 2015 15:00:37 -0700

> Conntrack LABELS (plural) are exposed by conntrack; rename the OVS name
> for these to be consistent with conntrack.
> 
> Fixes: c2ac667 "openvswitch: Allow matching on conntrack label"
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v3: Fix build with !CONFIG_NF_CONNTRACK
> v2: Change ct_label struct names as well as constants.

Applied, thanks.
