From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] iproute2 skbedit: Fix help message
Date: Sat, 26 Dec 2009 11:07:48 -0800
Message-ID: <20091226110748.2a76660d@nehalam>
References: <1259846844.3766.36.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58128 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbZLZTIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Dec 2009 14:08:10 -0500
In-Reply-To: <1259846844.3766.36.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Dec 2009 08:27:24 -0500
jamal <hadi@cyberus.ca> wrote:

> 
> Currently the help text for skbedit implies you can either pass queue
> mapping or priority. Truth is you can pass both
> 
> cheers,
> jamal
> 
applied to 2.6.32 version

-- 
