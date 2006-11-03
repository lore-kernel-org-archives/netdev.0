From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Wake On Lan device semantics
Date: Fri, 03 Nov 2006 15:44:13 -0800
Message-ID: <454BD44D.2060005@intel.com>
References: <20061103152025.5d27bd8d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3129 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S932504AbWKCXoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 18:44:15 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061103152025.5d27bd8d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> It doesn't seem like a good idea for a network device to wake the system
> if it is down.

before suspend existed this was the only useful case for WoL. Why does it not seem a 
good idea to wake up a machine that was shutdown (and thus the interface `downed`) ?

Auke
