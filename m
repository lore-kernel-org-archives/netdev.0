From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 19/26] phylink: add flow control support
Date: Thu, 07 Jan 2016 12:25:47 -0800
Message-ID: <568EC9CB.2000200@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zkO-00076Q-Q8@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33755 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbcAGU0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:26:21 -0500
Received: by mail-pa0-f44.google.com with SMTP id cy9so266935610pac.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:26:21 -0800 (PST)
In-Reply-To: <E1a5zkO-00076Q-Q8@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:38, Russell King wrote:
> Add flow control support, including ethtool support, to phylink.  We
> add support to allow ethtool to get and set the current flow control
> settings, and the 802.3 specified resolution for the local and remote
> link partner abilities.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
