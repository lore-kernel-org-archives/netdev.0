From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Re: Hung up was occurred after v4.4-rc1 during IPv6 Ready Logo
 Conformance Test
Date: Thu, 17 Mar 2016 16:40:41 +0900
Message-ID: <56EA5F79.8030802@jp.fujitsu.com>
References: <56E0F631.7010906@jp.fujitsu.com>
 <20160310063919.GA76112@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:26588 "EHLO
	mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080AbcCQHks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 03:40:48 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id C903AAC03E9
	for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 16:40:41 +0900 (JST)
In-Reply-To: <20160310063919.GA76112@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

Thank you for your reply.
Sorry for the delay.

On 2016=E5=B9=B403=E6=9C=8810=E6=97=A5 15:39, Martin KaFai Lau wrote:
> On Thu, Mar 10, 2016 at 01:21:05PM +0900, Yuki Machida wrote:
>> Hi all,
>>
>> Hung up was occurred at Linux Kernel after v4.4-rc1 during IPv6 Read=
y Logo Conformance Test.
>> Not Fix a bug in v4.5-rc7 yet.
>>
>> Currently, it is under investigation.
>>
>> The following are the details:
> I think you forgot to paste the details?
I found that this problem don't cause a hang-up.
I will report again after more investigation.

>
>>
>> IPv6 Ready Logo
>> https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__www.ipv6ready=
=2Eorg_&d=3DCwICJg&c=3D5VD0RTtNlTh3ycd41b3MUw&r=3DVQnoQ7LvghIj0gVEaiQSU=
w&m=3DBzjeED6xB_NfQBjateVt8Gh7IK7hST7tSmPGXEAtRdQ&s=3DoaM204vOhRnGb6aTD=
1wxTZu9ss_bCzFAeZU0EmvVe6I&e=3D
>>
>> I ran the IPv6 Ready Logo Core Conformance Test on Intel D510MO (Ato=
m D510).
>> It is using userland build with yocto project.
>>
>> Test Environment
>> Test Specification          : 4.0.6
>> Tool Version                : REL_3_3_2
>> Test Program Version        : V6LC_5_0_0
>> Target Device               : Intel D510MO (Atom D510)
>>
>> Regards,
>> Yuki Machida
>
