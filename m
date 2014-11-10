From: Jianhua Xie <jianhua.xie@freescale.com>
Subject: Re: [PATCH RFC net-next 0/5] *** Introduce 4 AD link speed ***
Date: Mon, 10 Nov 2014 15:21:04 +0800
Message-ID: <54606760.5000503@freescale.com>
References: <1415274772-8029-1-git-send-email-Jianhua.Xie@freescale.com>
 <20141107.151918.371340447814973895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0129.outbound.protection.outlook.com ([207.46.100.129]:56864
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750933AbaKJHfk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2014 02:35:40 -0500
In-Reply-To: <20141107.151918.371340447814973895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a lot for the valuable comments.
New patches set is coming.

Best Regards,
Jianhua

=E5=9C=A8 2014=E5=B9=B411=E6=9C=8808=E6=97=A5 04:19, David Miller =E5=86=
=99=E9=81=93:
> From: Xie Jianhua <Jianhua.Xie@freescale.com>
> Date: Thu, 6 Nov 2014 19:52:47 +0800
>
>> From: Jianhua Xie <Jianhua.Xie@freescale.com>
>>
>> User Key bits in Port key of AD mode are yet not used.  This series
>> expands speed type bits and shrinks unused user Key bits in AD mode
>> Port Key, introduces 4 AD link speed: 2.5G/20G/40G/56G, and fixes
>> aggregated link bandwidth calculation based on new link speed.
> I think you can compress patches #2 to #5 into one single patch.
