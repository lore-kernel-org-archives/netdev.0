From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch 2/5] s2io driver updates
Date: Mon, 24 Apr 2006 10:57:50 -0700
Message-ID: <20060424105750.7c097634@localhost.localdomain>
References: <20060424102203.3cb5e29b@localhost.localdomain>
	<200604241740.k3OHepDr023452@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, <jgarzik@pobox.com>,
	<netdev@vger.kernel.org>, <leonid.grossman@neterion.com>,
	<ravinandan.arakali@neterion.com>, <rapuru.sriram@neterion.com>,
	<alicia.pena@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:5086 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751075AbWDXR55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 13:57:57 -0400
To: "Ananda Raju" <ananda.raju@neterion.com>
In-Reply-To: <200604241740.k3OHepDr023452@guinness.s2io.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Apr 2006 10:39:52 -0700
"Ananda Raju" <ananda.raju@neterion.com> wrote:

> Hi, 
> 
> Currently the only way we can differentiate between copper CX4 transponder
> adapters from optical transponder adapters is by reading the product name
> string in vpd. 

That makes sense.  Though often the VPD can be messed up by OEM's. Probably
not a big issue with this driver.
