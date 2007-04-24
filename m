From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 2/3] ne: MIPS: Use platform_driver for ne on RBTX49XX
Date: Wed, 25 Apr 2007 02:03:55 +0900 (JST)
Message-ID: <20070425.020355.70477311.anemo@mba.ocn.ne.jp>
References: <20070425.015549.108742168.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, ralf@linux-mips.org,
	sshtylyov@ru.mvista.com
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:56800 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422765AbXDXRD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 13:03:56 -0400
In-Reply-To: <20070425.015549.108742168.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Apr 2007 01:55:49 +0900 (JST), Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
> This patch lets RBTX49XX boards use generic platform_driver interface
> for the ne driver.

This patch obsolates a patch I send on 1 Mar.

> Subject: [PATCH] Fix broken RBTX4927 support in ne.c
> Message-Id: <20070301.012223.129448787.anemo@mba.ocn.ne.jp>
> Date: 	Thu, 01 Mar 2007 01:22:23 +0900 (JST)

I revoke this old patch if new patch was acceptable.

---
Atsushi Nemoto
