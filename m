From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 5/5] net-next:asix: v2 update VERSION only
Date: Tue, 15 Nov 2011 16:34:25 -0800
Message-ID: <4EC30511.6030807@hp.com>
References: <1321318357-17723-1-git-send-email-grundler@chromium.org> <21257.1321403368@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@chromium.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Allan Chou <allan@asix.com.tw>, Freddy Xin <freddy@asix.com.tw>
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:39459 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932742Ab1KPAe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 19:34:28 -0500
In-Reply-To: <21257.1321403368@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2011 04:29 PM, Valdis.Kletnieks@vt.edu wrote:
> On Mon, 14 Nov 2011 16:52:37 PST, Grant Grundler said:
>
>> -#define DRIVER_VERSION "26-Sep-2011"
>> +#define DRIVER_VERSION "08-Nov-2011"
>
> Aren't these sort of things more than a tad silly for an in-kernel driver?

Probably depends on whether or not a distro back-ports something from 
upstream.

rick jones
