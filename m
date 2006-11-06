From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/2] forcedeth: add recoverable error support
Date: Mon, 06 Nov 2006 03:12:01 -0500
Message-ID: <454EEE51.1050003@pobox.com>
References: <45467D61.1030502@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:3715 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1422626AbWKFIMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 03:12:09 -0500
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <45467D61.1030502@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch adds support to recover from a previously fatal MAC error. In 
> the past the MAC would be hung on an internal fatal error. On new 
> chipsets, the MAC has the ability to enter a non-fatal state and allow 
> the driver to re-init it.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

applied


