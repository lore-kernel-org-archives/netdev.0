From: Ben Pfaff <blp@nicira.com>
Subject: Re: [PATCH v2.40 1/7] odp: Only pass vlan_tci to commit_vlan_action()
Date: Fri, 27 Sep 2013 09:56:46 -0700
Message-ID: <20130927165646.GO492@nicira.com>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
 <1380241116-7661-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:45324 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753004Ab3I0Q4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 12:56:52 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so2817455pdj.8
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 09:56:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1380241116-7661-2-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 09:18:30AM +0900, Simon Horman wrote:
> From: Joe Stringer <joe@wand.net.nz>
> 
> This allows for future patches to pass different tci values to
> commit_vlan_action() without passing an entire flow structure.
> 
> Signed-off-by: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied, thanks.
