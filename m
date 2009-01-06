From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] qlge: Fix sparse endian warning in
 ql_hw_csum_setup().
Date: Mon, 05 Jan 2009 18:18:56 -0800 (PST)
Message-ID: <20090105.181856.157577963.davem@davemloft.net>
References: <20090105222600.GA4232@susedev.qlogic.org>
	<1231194452-10671-3-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47519
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751893AbZAFCSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 21:18:55 -0500
In-Reply-To: <1231194452-10671-3-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon,  5 Jan 2009 14:27:30 -0800

> Changed u16 to __sum16 usage.
> 
> Warnings:
 ...
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.

