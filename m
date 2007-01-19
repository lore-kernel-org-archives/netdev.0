From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e1000: update device ID table for register dumps [Is an *ethtool*
 patch]
Date: Fri, 19 Jan 2007 15:20:02 -0800
Message-ID: <45B15222.3000407@intel.com>
References: <20070119225313.297224186C@ahkok-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18570 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932623AbXASXUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 18:20:04 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <20070119225313.297224186C@ahkok-mobl.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> e1000: update device ID table for register dumps with new devices
> 
> From: Auke Kok <auke-jan.h.kok@intel.com>
> 
> The register dump routine of e1000 was missing several newer chipsets. I
> reimported the mac detection code from the linux e1000 driver. This fixes
> newer NIC's reporting that their bus type is PCI instead of PCI-e.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>


it's a patch to ethtool, of course. Apologies for any confusion. I didn't fix the mail 
subject.

Auke
