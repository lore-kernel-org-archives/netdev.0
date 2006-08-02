From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] htb: cleanup
Date: Wed, 02 Aug 2006 15:18:16 -0700 (PDT)
Message-ID: <20060802.151816.30182208.davem@davemloft.net>
References: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36481
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932277AbWHBWSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 18:18:18 -0400
To: shemminger@osdl.org
In-Reply-To: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 2 Aug 2006 12:56:36 -0700

> The HTB scheduler code is a mess, this patch set does some basic
> house cleaning.  The first four should cause no code change, but the
> last two need more testing.

These patches look fine to me.  Once everyone think's they
are ready just let me know and I'll push them into net-2.6.19
