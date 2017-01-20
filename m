From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip/xfrm: Fix deleteall when having many policies
 installed
Date: Fri, 20 Jan 2017 09:22:44 -0800
Message-ID: <20170120092201.665b3d32@xeon-e3>
References: <d056322e-7c23-7e19-3bdb-4afa5f04e409@secunet.com>
        <20170118090302.6efd6cce@xeon-e3>
        <51b5293a-bce8-b663-f9de-97dc7c8113b3@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <shemminger@osdl.org>
To: Alexander Heinlein <alexander.heinlein@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33646 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbdATRcf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:32:35 -0500
Received: by mail-pf0-f177.google.com with SMTP id y143so23947710pfb.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 09:32:35 -0800 (PST)
In-Reply-To: <51b5293a-bce8-b663-f9de-97dc7c8113b3@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2017 08:57:56 +0100
Alexander Heinlein <alexander.heinlein@secunet.com> wrote:

> From 192cf19b3a97871a508ad57ba5893d1719877f13 Mon Sep 17 00:00:00 2001
> From: Alexander Heinlein <alexander.heinlein@secunet.com>
> Date: Mon, 16 Jan 2017 14:48:25 +0100
> Subject: [PATCH] ip/xfrm: Fix deleteall when having many policies installed
> 
> Fix "Policy buffer overflow" when trying to use deleteall with many
> policies installed.
> 
> Signed-off-by: Alexander Heinlein <alexander.heinlein@secunet.com>

Applied thanks.
