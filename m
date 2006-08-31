From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Probably e1000 related Oops in 2.6.18-rc5
Date: Thu, 31 Aug 2006 11:47:02 -0700
Message-ID: <44F72EA6.7020303@intel.com>
References: <Pine.LNX.4.64.0608311803220.28922@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35251 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S932321AbWHaSs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 14:48:29 -0400
To: Krzysztof Oledzki <olel@ans.pl>
In-Reply-To: <Pine.LNX.4.64.0608311803220.28922@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Oledzki wrote:
> Hello,
> 
> My testing workstation running 2.6.18-rc5 Oopsed. It has a dualport 
> e1000 card with bonding and vlans.
> 
> All I have is three fotos made by a digital camera: 
> http://www.ans.pl/Oops/1/
> 
> Hope it is enough.

unfortunately the top of the OOPS is gone, and bonding+vlans makes this really 
very icky. I'm not quite sure this is an e1000 specific problem.

Auke
