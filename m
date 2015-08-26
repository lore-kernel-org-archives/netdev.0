From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v3 net-next 4/8] geneve: Make dst-port configurable.
Date: Wed, 26 Aug 2015 16:47:50 -0400
Message-ID: <20150826204749.GD9495@tuxdriver.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
 <1440438195-5695-5-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58316 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbbHZVAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 17:00:13 -0400
Content-Disposition: inline
In-Reply-To: <1440438195-5695-5-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 10:43:11AM -0700, Pravin B Shelar wrote:
> Add netlink interface to configure Geneve UDP port number.
> So that user can configure it for a Gevene device.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> Reviewed-by: Jesse Gross <jesse@nicira.com>

Acked-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
