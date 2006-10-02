From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 1/2] remove Momentum Jaguar ATX network driver support
Date: Mon, 2 Oct 2006 16:22:06 +0100
Message-ID: <20061002152206.GB25180@linux-mips.org>
References: <20061002233344.4e09116b.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:26550 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S964978AbWJBXet
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 19:34:49 -0400
Received: from localhost.localdomain ([127.0.0.1]:59338 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20038824AbWJBXer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 00:34:47 +0100
To: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Content-Disposition: inline
In-Reply-To: <20061002233344.4e09116b.yoichi_yuasa@tripeaks.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2006 at 11:33:44PM +0900, Yoichi Yuasa wrote:

> This patch has removed Momentum / PMC-Sierra Jaguar ATX network driver support.
> It is listed in feature-removal-schedule.txt .

NAK.  I won't remove the Momentum / Ocelot support for now.

  Ralf
