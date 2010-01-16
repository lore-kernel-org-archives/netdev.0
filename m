From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 NEXT 0/2]qlcnic: Qlogic ethernet driver for CNA
 devices
Date: Sat, 16 Jan 2010 01:25:26 -0800 (PST)
Message-ID: <20100116.012526.232349039.davem@davemloft.net>
References: <1263379046-30262-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48753
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752199Ab0APJZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 04:25:16 -0500
In-Reply-To: <1263379046-30262-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Wed, 13 Jan 2010 02:37:24 -0800

> Hi,
>    This is the fixed patch series v4, incorporating Ben Hutchings suggestions.
>    - Fixing License header
>    - Unused #define removed
>    - Using kernel defines
>    - printk removed, using dev_info, dev_err and dev_warn
>    - Fix : default initialization of variable
>    - read mac address fixed
>    - interrupt coalescing fixed

Applied to net-next-2.6, thanks.
