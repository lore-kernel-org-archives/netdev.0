From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] drivers: net: ethernet: cpsw: consider number of slaves
 in interation
Date: Tue, 26 Feb 2013 20:25:46 +0530
Message-ID: <512CCCF2.7030306@ti.com>
References: <1361887580-1770-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:56710 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932091Ab3BZOzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 09:55:55 -0500
In-Reply-To: <1361887580-1770-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/26/2013 7:36 PM, Daniel Mack wrote:
> Make cpsw_add_default_vlan() look at the actual number of slaves for its
> iteration, so boards with less than 2 slaves don't ooops at boot.
>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Cc: David S. Miller <davem@davemloft.net>
Looks ok for me

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
