From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] macvlan: Fix checksum errors when ip_summed is CHECKSUM_PARTIAL
Date: Mon, 19 May 2014 13:36:21 -0700
Message-ID: <CAHA+R7PKPRkC5hvsS=M3muo4pzH8XrvP2c7=qR1Yo_dS5Yh-yA@mail.gmail.com>
References: <1400520254-5142-1-git-send-email-spang@chromium.org>
	<1400521493.5367.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAC5F_1mrXgEtx7sx1ihdm5EA6cxP7cA7mOjVmP8HvWxatgAcRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>
To: Michael Spang <spang@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAC5F_1mrXgEtx7sx1ihdm5EA6cxP7cA7mOjVmP8HvWxatgAcRA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 19, 2014 at 1:05 PM, Michael Spang <spang@chromium.org> wrote:
> On Mon, May 19, 2014 at 1:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>> I removed stable@ , as stable submissions are not done like that.
>>
>
> Perhaps I've misunderstood something, but this suggestion is right
> from https://www.kernel.org/doc/Documentation/stable_kernel_rules.txt
>
>  - To have the patch automatically included in the stable tree, add the tag
>      Cc: stable@vger.kernel.org
>    in the sign-off area. Once the patch is merged it will be applied to
>    the stable tree without anything else needing to be done by the author
>    or subsystem maintainer.

netdev has different rules, you need to check
Documentation/networking/netdev-FAQ.txt.
