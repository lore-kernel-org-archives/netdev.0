From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Re: Backport Security Fix for CVE-2015-8787 to v4.1
Date: Mon, 11 Apr 2016 13:58:59 +0900
Message-ID: <570B2F13.9000201@jp.fujitsu.com>
References: <570600DE.2030001@jp.fujitsu.com> <20160407144628.GA1137@salvia>
 <570B2B4E.2080303@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kamatam@amazon.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym03.jp.fujitsu.com ([211.128.242.42]:35207 "EHLO
	mgwym03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbcDKE7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 00:59:05 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 9F9CCAC01A8
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 13:58:59 +0900 (JST)
In-Reply-To: <570B2B4E.2080303@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

On 2016=E5=B9=B404=E6=9C=8811=E6=97=A5 13:42, Yuki Machida wrote:
> Hi Pablo,
>
> On 2016=E5=B9=B404=E6=9C=8807=E6=97=A5 23:46, Pablo Neira Ayuso wrote=
:
>> On Thu, Apr 07, 2016 at 03:40:30PM +0900, Yuki Machida wrote:
>>> Hi David,
>>>
>>> I conformed that a patch of CVE-2015-8787 not applied at v4.1.21.
>>> Could you please apply a patch for 4.1-stable ?
>>>
>>> CVE-2015-8787
>>> Upstream commit 94f9cd81436c85d8c3a318ba92e236ede73752fc
>>
>> I'll request again, this time to Sasha Levin to include this in
>> -stable 4.1.
> Thank you for your help.
David said "Please send to the netfilter team".
Therefore, I will send above patch to netfilter team.

Thank you.
>> Thanks.
>>
>
