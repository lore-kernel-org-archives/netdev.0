From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2 v2] ip netns: Fix rtnl error while print netns
 list
Date: Tue, 10 Mar 2015 16:43:42 +0100
Message-ID: <54FF112E.5030402@6wind.com>
References: <1425709858-25644-1-git-send-email-vadim4j@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:34158 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbbCJPno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 11:43:44 -0400
Received: by wgha1 with SMTP id a1so2796366wgh.1
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 08:43:43 -0700 (PDT)
In-Reply-To: <1425709858-25644-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/03/2015 07:30, Vadim Kochan a =C3=A9crit :
> From: Vadim Kochan <vadim4j@gmail.com>
>
> Observed on the Linux 3.18:
>
>      # ip netns
>      RTNETLINK answers: Operation not supported
>      net0
>
> CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Fixes: d182ee1307c7 ("ipnetns: allow to get and set netns ids")
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
Thank you for taking care of this.
