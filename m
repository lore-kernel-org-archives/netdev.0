From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: RXHASH flag support (v2)
Date: Tue, 06 Apr 2010 10:44:40 -0400
Message-ID: <4BBB48D8.70302@garzik.org>
References: <20100402081515.1b963562@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:60788 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387Ab0DFOoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 10:44:46 -0400
Received: by qyk9 with SMTP id 9so2245861qyk.1
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 07:44:45 -0700 (PDT)
In-Reply-To: <20100402081515.1b963562@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/2010 11:15 AM, Stephen Hemminger wrote:
> Add support for RXHASH flag in ethtool offload.
>
> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
> ---
>   ethtool-copy.h |    1 +
>   ethtool.8      |    4 ++++
>   ethtool.c      |   39 ++++++++++++++++++++++++++++++++++-----
>   3 files changed, 39 insertions(+), 5 deletions(-)

applied


