From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Hung up was occurred after v4.4-rc1 during IPv6 Ready Logo
 Conformance Test
Date: Thu, 10 Mar 2016 13:21:05 +0900
Message-ID: <56E0F631.7010906@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym01.jp.fujitsu.com ([211.128.242.40]:28122 "EHLO
	mgwym01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932238AbcCJEVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 23:21:12 -0500
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 90BE8AC02F6
	for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 13:21:05 +0900 (JST)
Received: from omame (omame.fct.css.fujitsu.com [10.24.14.171])
	by m3050.s.css.fujitsu.com (Postfix) with ESMTP id 86D99172
	for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 13:21:05 +0900 (JST)
Received: from [10.24.19.86] (ubi86.utsfd.cs.fujitsu.co.jp [10.24.19.86])
	by omame (Postfix) with ESMTPSA id 763951E0088
	for <netdev@vger.kernel.org>; Thu, 10 Mar 2016 13:21:05 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Hung up was occurred at Linux Kernel after v4.4-rc1 during IPv6 Ready Logo Conformance Test.
Not Fix a bug in v4.5-rc7 yet.

Currently, it is under investigation.

The following are the details:

IPv6 Ready Logo
https://www.ipv6ready.org/

I ran the IPv6 Ready Logo Core Conformance Test on Intel D510MO (Atom D510).
It is using userland build with yocto project.

Test Environment
Test Specification          : 4.0.6
Tool Version                : REL_3_3_2
Test Program Version        : V6LC_5_0_0
Target Device               : Intel D510MO (Atom D510)

Regards,
Yuki Machida
