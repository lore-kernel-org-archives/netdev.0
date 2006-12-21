From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Network drivers that don't suspend on interface down
Date: Thu, 21 Dec 2006 12:18:33 +0100
Message-ID: <20061221111833.GA25184@electric-eye.fr.zoreil.com>
References: <20061220053417.GA29877@suse.de> <20061220055209.GA20483@srcf.ucam.org> <1166601025.3365.1345.camel@laptopd505.fenrus.org> <20061220125314.GA24188@srcf.ucam.org> <1166621931.3365.1384.camel@laptopd505.fenrus.org> <20061220143134.GA25462@srcf.ucam.org> <1166629900.3365.1428.camel@laptopd505.fenrus.org> <20061220144906.7863bcd3@dxpl.pdx.osdl.net> <20061221001111.GA4016@electric-eye.fr.zoreil.com> <20061219162608.6085d8aa@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46524 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964845AbWLULWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 06:22:39 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061219162608.6085d8aa@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> We need to allow ethtool setting to be done before device has been brought
> up and started autonegotiation. The current MII library doesn't really support
> it.

I completely agree.

-- 
Ueimor
