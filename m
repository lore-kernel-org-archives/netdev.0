From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/5] sky2: restore vlan acceleration on reset
Date: Wed, 21 May 2008 10:02:45 -0700
Message-ID: <20080521100245.1fc77369@extreme>
References: <20080515000412.984337700@vyatta.com>
	<20080515000432.887028646@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40873 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187AbYEURCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 13:02:52 -0400
In-Reply-To: <20080515000432.887028646@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2008 17:04:13 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> If device has to be reset by sky2_restart, then need to restore
> the VLAN acceleration settings.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Please apply to 2.6.26

Okay, it has been a week with no reply, what is the status
of these patches?
