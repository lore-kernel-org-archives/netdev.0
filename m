From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Re: [requrest for stable 4.1.y inclution] Fix for CVE-2015-7799
Date: Fri, 15 Jan 2016 11:52:45 +0900
Message-ID: <56985EFD.7050605@jp.fujitsu.com>
References: <56978CFE.1010703@jp.fujitsu.com>
 <1452777529.7020.67.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym04.jp.fujitsu.com ([211.128.242.43]:62836 "EHLO
	mgwym04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbcAOCwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 21:52:50 -0500
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 05338AC03E2
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 11:52:46 +0900 (JST)
In-Reply-To: <1452777529.7020.67.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016=E5=B9=B401=E6=9C=8814=E6=97=A5 22:18, Ben Hutchings wrote:
> On Thu, 2016-01-14 at 20:56 +0900, Yuki Machida wrote:
>> This patch is the fix for CVE-2015-7799
>> Upstream commit 4ab42d78e37a294ac7bc56901d563c642e03c4ae
>>
>> Stable 3.2.y has included this patch in v3.2.75.
>> https://cdn.kernel.org/pub/linux/kernel/v3.x/ChangeLog-3.2.75
>>
>> Please include in this patch to stable 4.1.y.
>
> Commit 0baa57d8dc32db78369d8b5176ef56c5e2e18ab3 is also needed as
> preparation.
>
> Ben.
>
Thanks for your comment, Ben.

Two patches is the fix for CVE-2015-7799.
commit 4ab42d78e37a294ac7bc56901d563c642e03c4ae
commit 0baa57d8dc32db78369d8b5176ef56c5e2e18ab3

Please include in these patch to -stable.
