From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv3] openvswitch: Rename LABEL->LABELS
Date: Thu, 1 Oct 2015 15:23:53 -0700
Message-ID: <CALnjE+rF7HLGH0PkYZKQsdnOC_GqO8E+kLUHMR1ZnCT5m47avA@mail.gmail.com>
References: <201510020526.yYUtAeEs%fengguang.wu@intel.com>
	<1443736837-9581-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443736837-9581-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 1, 2015 at 3:00 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Conntrack LABELS (plural) are exposed by conntrack; rename the OVS name
> for these to be consistent with conntrack.
>
> Fixes: c2ac667 "openvswitch: Allow matching on conntrack label"
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v3: Fix build with !CONFIG_NF_CONNTRACK
> v2: Change ct_label struct names as well as constants.
> ---
Acked-by: Pravin B Shelar <pshelar@nicira.com>
