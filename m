From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] ss: Filtering fixes for unix & netlink
 socks
Date: Tue, 24 Feb 2015 17:39:49 -0800
Message-ID: <20150224173949.0caeccb4@urahara>
References: <1424636591-19903-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:41371 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492AbbBYBjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 20:39:47 -0500
Received: by iecrd18 with SMTP id rd18so1074837iec.8
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 17:39:46 -0800 (PST)
In-Reply-To: <1424636591-19903-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 Feb 2015 22:23:09 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> Some fixes when filtering unix & netlink sockets.
> 
> Vadim Kochan (2):
>   ss: Add filter before printing unix stats from Netlink
>   ss: Skip filtered netlink sockets before detailed info
> 
>  misc/ss.c | 17 +++++++++++------
>  1 file changed, 11 insertions(+), 6 deletions(-)
> 

Applied
