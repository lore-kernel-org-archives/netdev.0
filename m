From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: Showing peer of veth type dev in ip link (ip cmd
 side)
Date: Fri, 4 Oct 2013 11:23:50 -0700
Message-ID: <20131004112350.06818715@nehalam.linuxnetplumber.net>
References: <1380859565-32388-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:38800 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524Ab3JDSXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 14:23:54 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so4322463pbc.26
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 11:23:53 -0700 (PDT)
In-Reply-To: <1380859565-32388-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  4 Oct 2013 13:06:05 +0900
Masatake YAMATO <yamato@redhat.com> wrote:

> Implement print_opt method to veth to show peer ifindex
> as ethtool -S does.
> 
> A patch submitted with following subject is needed:
> 
>    veth: Showing peer of veth type dev in ip link (kernel side)
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

NAK, see kernel comments
