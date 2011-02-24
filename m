From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] cls_u32: fix sparse warnings
Date: Wed, 23 Feb 2011 19:47:15 -0500
Message-ID: <1298508435.7672.0.camel@mojatatu>
References: <20110220181423.492594b7@nehalam>
	 <1298464542.2271.1.camel@mojatatu>  <20110223101614.1cdc9d51@nehalam>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:53615 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754932Ab1BXArS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 19:47:18 -0500
Received: by iyb26 with SMTP id 26so4996iyb.19
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 16:47:18 -0800 (PST)
In-Reply-To: <20110223101614.1cdc9d51@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-02-23 at 10:16 -0800, Stephen Hemminger wrote:


> With current sparse and net-next it comes up clean.

weird. So _data has to be defined on the stack for sparse 
to complain?
Another one is act_pedit.c

cheers,
jamal

