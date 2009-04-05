From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH 1/10] Staging: at76: convert to netdev_ops
Date: Sun, 5 Apr 2009 04:50:21 +0400
Message-ID: <a4423d670904041750i194b4351ib08cd18f4a5b7394@mail.gmail.com>
References: <20090329152334.GA11056@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:47007 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755352AbZDEAuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 20:50:24 -0400
In-Reply-To: <20090329152334.GA11056@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/3/29 Alexander Beregalov <a.beregalov@gmail.com>:
>
>
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

Greg, these patches fix build failures when CONFIG_COMPAT_NET_DEV_OPS
is not set.
I think they should be in 2.6.30 also.
