From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH] TI DaVinci EMAC: Convert to dev_pm_ops
Date: Fri, 12 Mar 2010 15:28:47 -0800
Message-ID: <87zl2d3ys0.fsf@deeprootsystems.com>
References: <1268296676-12514-1-git-send-email-chaithrika@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, davem@davemloft.net
To: Chaithrika U S <chaithrika@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:48007 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934713Ab0CLX2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 18:28:49 -0500
Received: by iwn6 with SMTP id 6so155797iwn.4
        for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 15:28:49 -0800 (PST)
In-Reply-To: <1268296676-12514-1-git-send-email-chaithrika@ti.com> (Chaithrika U. S.'s message of "Thu\, 11 Mar 2010 14\:07\:56 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chaithrika U S <chaithrika@ti.com> writes:

> Migrate from the legacy PM hooks to use dev_pm_ops structure.
>
> Signed-off-by: Chaithrika U S <chaithrika@ti.com>

Acked-by: Kevin Hilman <khilman@deeprootsystems.com>
