From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH] ipv6: ipv6_create_tempaddr cleanup
Date: Mon, 02 Sep 2013 22:32:44 +0800
Message-ID: <5224A18C.5060802@gmail.com>
References: <1377874958-2426-1-git-send-email-pholasek@redhat.com> <20130901183533.GB19455@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Petr Holasek <pholasek@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130901183533.GB19455@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2013/9/2 2:35, Hannes Frederic Sowa =E5=86=99=E9=81=93:
> On Fri, Aug 30, 2013 at 05:02:38PM +0200, Petr Holasek wrote:
>> This two-liner removes max_addresses variable which is now unecessar=
y related
>> to patch [ipv6: remove max_addresses check from ipv6_create_tempaddr=
].
>>
>> Signed-off-by: Petr Holasek <pholasek@redhat.com>
> Uh, yes, I missed that. Thanks a lot!
>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Ding Tianhong <dingtianhong@huawei.com>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
