From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH 1/2] Fix phy_init for Marvell network eth driver
Date: Thu, 10 Jan 2013 17:22:27 +0400
Message-ID: <50EEC093.4080505@mvista.com>
References: <1357819234-27752-1-git-send-email-konszert@marvell.com> <1357819234-27752-2-git-send-email-konszert@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alior@marvell.com, andrew@lunn.ch,
	benavi@marvell.com, zertsekel@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: Kosta Zertsekel <konszert@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:50011 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab3AJNWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 08:22:43 -0500
Received: by mail-la0-f49.google.com with SMTP id fk20so552065lab.22
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 05:22:41 -0800 (PST)
In-Reply-To: <1357819234-27752-2-git-send-email-konszert@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10-01-2013 16:00, Kosta Zertsekel wrote:

> At least it fixes DNS323_REV_C1 board case (mach-orion5x/dsn323-setup.c file).

> Change-Id: I37d64795f79c358f66a211a150cec2263e40e295

    This line has no place in the upstream commit, please remove it. Also, the 
patch misses your signoff, so  couldn't be applied anyway. Same about the next 
patch.

WBR, Sergei
