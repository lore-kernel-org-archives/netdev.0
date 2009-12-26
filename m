From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] iproute2 skbedit: Add support to mark packets
Date: Sat, 26 Dec 2009 11:08:19 -0800
Message-ID: <20091226110819.1040b9cd@nehalam>
References: <1259847168.3766.40.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58145 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753458AbZLZTIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Dec 2009 14:08:35 -0500
In-Reply-To: <1259847168.3766.40.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Dec 2009 08:32:48 -0500
jamal <hadi@cyberus.ca> wrote:

> I did this originally because i was getting too many support
> questions on ipt with mark. It still makes sense since skbedit
> seems to be the mother action of skb metadata (should probably
> have been called skbmeta).
> 
> cheers,
> jamal

applied to repository for next version (header changes for 2.6.33
already done)

-- 
