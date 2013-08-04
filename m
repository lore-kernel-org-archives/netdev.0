From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v6 2/8] vxlan: Restructure vxlan receive.
Date: Sun, 4 Aug 2013 14:43:34 -0700
Message-ID: <20130804144334.5726f4b8@nehalam.linuxnetplumber.net>
References: <1375382685-3177-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:38028 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab3HDVnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 17:43:37 -0400
Received: by mail-pd0-f171.google.com with SMTP id bv13so2507016pdb.16
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 14:43:37 -0700 (PDT)
In-Reply-To: <1375382685-3177-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  1 Aug 2013 11:44:45 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> Use iptunnel_pull_header() for better code sharing.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

This patch is good.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
