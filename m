From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 4/9] net: ipmr: fix code and comment style
Date: Mon, 23 Nov 2015 11:40:28 +0100
Message-ID: <5652ED1C.6000902@cumulusnetworks.com>
References: <1448117852-4254-1-git-send-email-razor@blackwall.org>
 <1448117852-4254-5-git-send-email-razor@blackwall.org>
 <CAHA+R7ONwRv5cM8kn-7RML+3ezhEs5D8zxt7ZrneyWtwSUGAXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <cwang@twopensource.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37291 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbbKWKkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 05:40:31 -0500
Received: by wmww144 with SMTP id w144so98478298wmw.0
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 02:40:30 -0800 (PST)
In-Reply-To: <CAHA+R7ONwRv5cM8kn-7RML+3ezhEs5D8zxt7ZrneyWtwSUGAXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2015 06:30 AM, Cong Wang wrote:
> On Sat, Nov 21, 2015 at 6:57 AM, Nikolay Aleksandrov
> <razor@blackwall.org> wrote:
>> -
>> -/*
>> - *     Setup for IP multicast routing
>> - */
>> +/* Setup for IP multicast routing */
>>  static int __net_init ipmr_net_init(struct net *net)
> 
> Comments like this one are never useful so can be just removed.
> 

Will do, this is not the point of the patch thought. There're also
incorrect comments that need to be changed or removed. All in
due time, this is just a small trivial step to abide the style.
