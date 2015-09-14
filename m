From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] ipv6: include NLM_F_REPLACE in route replace
 notifications
Date: Mon, 14 Sep 2015 10:44:42 +0200
Message-ID: <20150914084441.GA5382@unicorn.suse.cz>
References: <1442164713-54206-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nicolas.dichtel@6wind.com,
	Mazziesaccount@gmail.com, hannes@stressinduktion.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45418 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753353AbbINIoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2015 04:44:46 -0400
Content-Disposition: inline
In-Reply-To: <1442164713-54206-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 13, 2015 at 10:18:33AM -0700, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds NLM_F_REPLACE flag to ipv6 route replace notifications.
> This makes nlm_flags in ipv6 replace notifications consistent
> with ipv4.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Reviewed-by: Michal Kubecek <mkubecek@suse.cz>
