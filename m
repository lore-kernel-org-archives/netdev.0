From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/2] iproute2 skbedit: Fix help message
Date: Sat, 26 Dec 2009 16:12:46 -0500
Message-ID: <1261861966.3363.0.camel@bigi>
References: <1259846844.3766.36.camel@bigi>
	 <20091226110748.2a76660d@nehalam>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:35602 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbZLZVMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 16:12:54 -0500
Received: by qw-out-2122.google.com with SMTP id 8so631036qwh.37
        for <netdev@vger.kernel.org>; Sat, 26 Dec 2009 13:12:54 -0800 (PST)
In-Reply-To: <20091226110748.2a76660d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-12-26 at 11:07 -0800, Stephen Hemminger wrote:
> On Thu, 03 Dec 2009 08:27:24 -0500
> jamal <hadi@cyberus.ca> wrote:
> 
> > 
> > Currently the help text for skbedit implies you can either pass queue
> > mapping or priority. Truth is you can pass both
> > 
> > cheers,
> > jamal
> > 
> applied to 2.6.32 version

It is not in the 2.6.32 release - but seems harmless enough it can stay
in later versions.

cheers,
jamal

