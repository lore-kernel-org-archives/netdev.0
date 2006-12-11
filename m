From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 06/22] e1000: minor tso ipv6 cleanups
Date: Mon, 11 Dec 2006 09:42:21 -0500
Message-ID: <457D6E4D.3090703@pobox.com>
References: <20061208230209.30109.49157.stgit@gitlost.site> <20061208230257.30109.63706.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46342 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936261AbWLKOmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:42:24 -0500
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20061208230257.30109.63706.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Zero descriptor ip_config field and use skb_shinfo to detect IPV6 packet.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

ACK patches 4-6


