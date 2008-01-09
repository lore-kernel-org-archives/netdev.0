From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/6][NET] Simple ctl_table to ctl_path
 conversions.
Date: Wed, 09 Jan 2008 00:30:12 -0800 (PST)
Message-ID: <20080109.003012.237111193.davem@davemloft.net>
References: <47839C30.2040402@openvz.org>
	<47839CD1.4080505@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57617
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750844AbYAIIaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 03:30:13 -0500
In-Reply-To: <47839CD1.4080505@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 08 Jan 2008 18:54:57 +0300

> This patch includes many places, that only required
> replacing the ctl_table-s with appropriate ctl_paths
> and call register_sysctl_paths().
> 
> Nothing special was done with them.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
