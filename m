From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: vnet: relocate netlink code section comment
Date: Mon, 20 Jul 2015 11:51:24 -0700
Message-ID: <CAHA+R7NEXSM_p5i3544dzcmZA3_Ey=Ly3tk7hu0okq5AJOQT3g@mail.gmail.com>
References: <7f4c030ea15ee6217af4809c834a7cbebcd66709.1437291650.git.baruch@tkos.co.il>
	<CAHA+R7P63k8Fy+2fcXDdj1fKhYs+CUq=AihnoF7weM3ROnLnHA@mail.gmail.com>
	<20150720171252.GP13027@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:36221 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbbGTSvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 14:51:25 -0400
Received: by ykay190 with SMTP id y190so146138892yka.3
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 11:51:24 -0700 (PDT)
In-Reply-To: <20150720171252.GP13027@tarshish>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 20, 2015 at 10:12 AM, Baruch Siach <baruch@tkos.co.il> wrote:
> Hi Cong Wang,
>
> On Mon, Jul 20, 2015 at 10:07:00AM -0700, Cong Wang wrote:
>> On Sun, Jul 19, 2015 at 12:40 AM, Baruch Siach <baruch@tkos.co.il> wrote:
>> > The veth_setup() routine and the VETH_FEATURES macro are also part of the
>> > netlink interface (referenced from struct rtnl_link_ops). Include them under
>> > the netlink code section comment.
>>
>> Or just remove it? I don't think comment like this one is useful.
>
> The veth.c file contain a few more separator comments. Would you suggest to
> remove them all?
>

Yes, they look all useless for me myself.
