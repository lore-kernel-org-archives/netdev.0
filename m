From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2.6.21 2/4] cxgb3 - Auto-load FW if mismatch detected
Date: Wed, 21 Mar 2007 15:07:06 -0700
Message-ID: <20070321150706.9b916d79.akpm@linux-foundation.org>
References: <20070318201006.16292.12877.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:55654 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932817AbXCUWIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 18:08:00 -0400
In-Reply-To: <20070318201006.16292.12877.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 18 Mar 2007 13:10:06 -0700
divy@chelsio.com wrote:

>  config CHELSIO_T3
>          tristate "Chelsio Communications T3 10Gb Ethernet support"
>          depends on PCI
> +	select FW_LOADER

Something has gone wrong with the indenting there.
