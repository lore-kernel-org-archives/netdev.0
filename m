From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] ipv6: ipv6_find_hdr restore prev functionality
Date: Tue, 25 Feb 2014 20:33:12 +0400
Message-ID: <530CC5C8.7030907@cogentembedded.com>
References: <1393325651-11236-1-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>, netdev@vger.kernel.org,
	davem@davemloft.net, ja@ssi.bg, aatteka@nicira.com,
	kaber@trash.net, ard@telegraafnet.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:63334 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbaBYQdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 11:33:17 -0500
Received: by mail-lb0-f182.google.com with SMTP id n15so1190166lbi.27
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 08:33:16 -0800 (PST)
In-Reply-To: <1393325651-11236-1-git-send-email-hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25-02-2014 14:54, Hans Schillstrom wrote:

> The commit 9195bb8e381d81d5a315f911904cdf0cfcc919b8

    Please also specify that commit's summary line in parens.

> broke ipv6_find_hdr() for ipvs and possible also nft_exthdr_eval()
> This patch simple exit if specified header is found.

    s/exit/exits/.

> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

WBR, Sergei
