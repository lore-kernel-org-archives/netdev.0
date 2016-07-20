From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 0/6] iplink: Improve documentation
Date: Wed, 20 Jul 2016 12:13:07 -0700
Message-ID: <20160720121307.20b6cbc6@xeon-e3>
References: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35492 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbcGTTMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 15:12:52 -0400
Received: by mail-pa0-f53.google.com with SMTP id iw10so20895043pac.2
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 12:12:51 -0700 (PDT)
In-Reply-To: <1468056170-6056-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  9 Jul 2016 11:22:44 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series improves documentation around the feature of 'ip link set'
> to configure device type specific parameters. While doing so, I reviewed
> used fonts in ip-link.8 and fixed a few bugs/inconsistencies.
> 
> Phil Sutter (6):
>   iplink: List valid 'type' argument in ip link help text
>   iplink: bond_slave: Add missing help functions
>   ip-link.8: Extend type list in synopsis
>   ip-link.8: Place 'ip link set' warning more prominently
>   ip-link.8: Add slave type option descriptions
>   ip-link.8: Fix font choices
> 
>  ip/iplink.c            |   4 +-
>  ip/iplink_bond_slave.c |  24 ++++
>  man/man8/ip-link.8.in  | 314 +++++++++++++++++++++++++++++++++++--------------
>  3 files changed, 254 insertions(+), 88 deletions(-)
> 

Applied thanks
