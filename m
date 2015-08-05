From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv2 net-next 2/9] openvswitch: Move MASKED* macros to datapath.h
Date: Wed, 5 Aug 2015 15:30:17 -0700
Message-ID: <CALnjE+pA=bxYqMJhSLuTyTdTZdeukmjVjMgyrXjMrhNAbF5=2Q@mail.gmail.com>
References: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
	<1438750199-9061-3-git-send-email-joestringer@nicira.com>
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
In-Reply-To: <1438750199-9061-3-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 4, 2015 at 9:49 PM, Joe Stringer <joestringer@nicira.com> wrote:
> This will allow the ovs-conntrack code to reuse these macros.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
