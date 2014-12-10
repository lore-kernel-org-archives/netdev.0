From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] ip link: Show devices by type
Date: Tue, 9 Dec 2014 16:31:08 -0800
Message-ID: <20141209163108.456b8086@urahara>
References: <1417618598-23605-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:55290 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbaLJAbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 19:31:18 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so1601558pac.36
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 16:31:18 -0800 (PST)
In-Reply-To: <1417618598-23605-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 Dec 2014 16:56:38 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> Added new option 'type' to 'ip link show'
> command which allows to filter devices by type:
> 
>     ip link show type bridge
>     ip link show type vlan
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Does not apply to current iproute2 source.
Please update and resubmit
