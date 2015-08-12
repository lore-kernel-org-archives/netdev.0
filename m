From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv3 net-next 04/10] dst: Add __skb_dst_copy() variation
Date: Wed, 12 Aug 2015 14:35:07 -0700
Message-ID: <CALnjE+qUBLNX=M2jGjZemJkkXQYYh1R+acSFpZ+h7RW46v5gYg@mail.gmail.com>
References: <1439333961-24474-1-git-send-email-joestringer@nicira.com>
	<1439333961-24474-5-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>,
	Thomas Graf <tgraf@noironetworks.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439333961-24474-5-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 11, 2015 at 3:59 PM, Joe Stringer <joestringer@nicira.com> wrote:
> This variation on skb_dst_copy() doesn't require two skbs.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>


Acked-by: Pravin B Shelar <pshelar@nicira.com>
