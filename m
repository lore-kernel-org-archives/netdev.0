From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] ip netns: Fix rtnl error while print netns
 list
Date: Sun, 15 Mar 2015 12:19:10 -0700
Message-ID: <20150315121910.37b88950@urahara>
References: <1425709858-25644-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34944 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbbCOTTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:19:08 -0400
Received: by pabyw6 with SMTP id yw6so42448162pab.2
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 12:19:07 -0700 (PDT)
In-Reply-To: <1425709858-25644-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  7 Mar 2015 08:30:58 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Observed on the Linux 3.18:
> 
>     # ip netns
>     RTNETLINK answers: Operation not supported
>     net0
> 
> CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Fixes: d182ee1307c7 ("ipnetns: allow to get and set netns ids")
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Applied
