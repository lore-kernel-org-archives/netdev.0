From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] phy: remove documentation of removed members of
 phy_device structure
Date: Thu, 10 Mar 2016 09:53:50 -0800
Message-ID: <56E1B4AE.4010203@gmail.com>
References: <1457614738-17337-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34832 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbcCJRzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 12:55:23 -0500
In-Reply-To: <1457614738-17337-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/16 04:58, LABBE Corentin wrote:
> Commit e5a03bfd873c ("phy: Add an mdio_device structure") removed addr,
> bus and dev member of the phy_device structure.
> This patch remove the documentation about those members.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
