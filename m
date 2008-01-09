From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 4/6][AX25] Switch to using ctl_paths.
Date: Wed, 09 Jan 2008 00:32:31 -0800 (PST)
Message-ID: <20080109.003231.18949966.davem@davemloft.net>
References: <47839C30.2040402@openvz.org>
	<47839F3E.5080109@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57628
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751420AbYAIIcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 03:32:31 -0500
In-Reply-To: <47839F3E.5080109@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Jan 2008 19:05:18 +0300

> This one is almost the same as the hunks in the
> first patch, but ax25 tables are created dynamically.
> 
> So this patch differs a bit to handle this case.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
