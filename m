From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: Hung up was occurred after v4.4-rc1 during IPv6 Ready Logo
 Conformance Test
Date: Wed, 9 Mar 2016 22:39:19 -0800
Message-ID: <20160310063919.GA76112@kafai-mba.local>
References: <56E0F631.7010906@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Yuki Machida <machida.yuki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40991 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751571AbcCJGj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 01:39:29 -0500
Content-Disposition: inline
In-Reply-To: <56E0F631.7010906@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 01:21:05PM +0900, Yuki Machida wrote:
> Hi all,
>
> Hung up was occurred at Linux Kernel after v4.4-rc1 during IPv6 Ready Logo Conformance Test.
> Not Fix a bug in v4.5-rc7 yet.
>
> Currently, it is under investigation.
>
> The following are the details:
I think you forgot to paste the details?

>
> IPv6 Ready Logo
> https://urldefense.proofpoint.com/v2/url?u=https-3A__www.ipv6ready.org_&d=CwICJg&c=5VD0RTtNlTh3ycd41b3MUw&r=VQnoQ7LvghIj0gVEaiQSUw&m=BzjeED6xB_NfQBjateVt8Gh7IK7hST7tSmPGXEAtRdQ&s=oaM204vOhRnGb6aTD1wxTZu9ss_bCzFAeZU0EmvVe6I&e=
>
> I ran the IPv6 Ready Logo Core Conformance Test on Intel D510MO (Atom D510).
> It is using userland build with yocto project.
>
> Test Environment
> Test Specification          : 4.0.6
> Tool Version                : REL_3_3_2
> Test Program Version        : V6LC_5_0_0
> Target Device               : Intel D510MO (Atom D510)
>
> Regards,
> Yuki Machida
