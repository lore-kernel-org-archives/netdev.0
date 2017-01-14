From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: korina: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 14 Jan 2017 10:34:18 -0800
Message-ID: <5ae3f11a-e3d9-d9fd-1e89-6f568c17615b@gmail.com>
References: <1484393599-1547-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, davem@davemloft.net,
        mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de, jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35917 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdANSeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 13:34:19 -0500
In-Reply-To: <1484393599-1547-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2017 03:33 AM, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
