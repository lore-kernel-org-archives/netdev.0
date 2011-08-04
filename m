From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] cdc_ncm: fixes for big-endian architecture / MIPS
Date: Wed, 03 Aug 2011 19:11:41 -0700 (PDT)
Message-ID: <20110803.191141.888495095889424492.davem@davemloft.net>
References: <87hb5yock6.fsf@gnu.org>
	<2AC7D4AD8BA1C640B4C60C61C8E520153E3DEF6C26@EXDCVYMBSTM006.EQ1STM.local>
	<87ipqeebvg.fsf@gnu.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexey.orishko@stericsson.com, netdev@vger.kernel.org,
	oliver@neukum.org, linux-usb@vger.kernel.org, gregkh@suse.de,
	alexey.orishko@gmail.com
To: giuseppe@southpole.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755992Ab1HDCMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 22:12:00 -0400
In-Reply-To: <87ipqeebvg.fsf@gnu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Scrivano <giuseppe@southpole.se>
Date: Wed, 03 Aug 2011 17:46:43 +0200

>>From 7ba49d858103acb2ce4043127e3512ea29dff307 Mon Sep 17 00:00:00 2001
> From: Giuseppe Scrivano <giuseppe@southpole.se>
> Date: Fri, 15 Jul 2011 15:34:14 +0200
> Subject: [PATCH] cdc_ncm: fix endianess problem.
> 
> Signed-off-by: Giuseppe Scrivano <giuseppe@southpole.se>

The patch looks great, but please repost this fresh with a more
vebose commit log message explaining all the things we discussed
to get the change to it's current form.

Thanks!
