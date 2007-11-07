From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: add support for supporting 10000baseT
Date: Wed, 7 Nov 2007 16:57:50 +0000
Message-ID: <20071107165749.GB3320@solarflare.com>
References: <20071107162420.5102.26358.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fizeau.zen.co.uk ([212.23.8.67]:55659 "EHLO fizeau.zen.co.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755082AbXKGRB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 12:01:56 -0500
Received: from [212.23.3.142] (helo=rutherford.zen.co.uk)
	by fizeau.zen.co.uk with esmtp (Exim 4.50)
	id 1IpoHr-0001nx-3o
	for netdev@vger.kernel.org; Wed, 07 Nov 2007 17:01:55 +0000
Received: from [82.69.137.158] (helo=opal.uk.level5networks.com)
	by rutherford.zen.co.uk with esmtp (Exim 4.50)
	id 1IpoDx-0007oL-IW
	for netdev@vger.kernel.org; Wed, 07 Nov 2007 16:57:53 +0000
Received: from achroite (achroite.uk.level5networks.com [10.17.20.50])
	by opal.uk.level5networks.com (8.12.8/8.12.8) with ESMTP id lA7Gvouo008467
	for <netdev@vger.kernel.org>; Wed, 7 Nov 2007 16:57:53 GMT
Received: from bwh by achroite with local (Exim 4.62)
	(envelope-from <bwh@solarflare.com>)
	id 1IpoDu-0001jf-Rc
	for netdev@vger.kernel.org; Wed, 07 Nov 2007 16:57:50 +0000
Content-Disposition: inline
In-Reply-To: <20071107162420.5102.26358.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> there is missing support in ethtool for reporting 10000baseT
> as SUPPORTED_10000baseT_Full.  The code seems to be half
> implemented because the "advertising" field has the implementation.

I reported this lack on Sourceforge a while back:
<http://sourceforge.net/tracker/index.php?func=detail&aid=1798807&group_id=3242&atid=103242>
Is anyone reading bugs reported there?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
