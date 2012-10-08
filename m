From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: inform user when a neighbor is removed
Date: Mon, 8 Oct 2012 09:49:08 -0700
Message-ID: <20121008094908.192c21a5@nehalam.linuxnetplumber.net>
References: <1349424172-5602-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35087 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751883Ab2JHRA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 13:00:57 -0400
In-Reply-To: <1349424172-5602-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Oct 2012 10:02:52 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> When running 'ip monitor neigh', there is no hint to tell if a neighbor is
> updated or deleted.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---

Applied
