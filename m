From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: remove COMPAT_NET_DEV_OPS
Date: Sat, 23 May 2009 07:41:43 -0700
Message-ID: <20090523074143.445ef830@nehalam>
References: <1243088259-16482-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexander Beregalov <a.beregalov@gmail.com>
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55392 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522AbZEWOlr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2009 10:41:47 -0400
In-Reply-To: <1243088259-16482-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 May 2009 18:17:39 +0400
Alexander Beregalov <a.beregalov@gmail.com> wrote:

> All drivers are already converted to new net_device_ops API
> and nobody uses old API anymore.
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>

This go through the feature-removal-schedule process, to
allow other drivers that live outside the tree some notice for change.


-- 
