From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 4/7] openvswitch: Ensure flow is valid before
 executing ct
Date: Wed, 30 Sep 2015 17:31:28 -0700
Message-ID: <CALnjE+qiLFy7vhZK8mwW9ynRN-yB=smQxj2kVH0+Xv9ZbL8K_w@mail.gmail.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
	<1443566380-22640-5-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443566380-22640-5-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 29, 2015 at 3:39 PM, Joe Stringer <joestringer@nicira.com> wrote:
> The ct action uses parts of the flow key, so we need to ensure that it
> is valid before executing that action.
>
> Fixes: 7f8a436 "openvswitch: Add conntrack action"
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
