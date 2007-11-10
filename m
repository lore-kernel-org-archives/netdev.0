From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 00/05] pull request for 'upstream-jeff' branch
Date: Sat, 10 Nov 2007 00:33:31 -0500
Message-ID: <473542AB.6050105@pobox.com>
References: <20071108230734.GA15968@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Mark Lord <mlord@pobox.com>,
	Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>,
	Josh Logan <joshtlogan@gmail.com>,
	cecco <f.cecco77@tiscali.it>,
	Hans-Jurgen Koch <hjk@linutronix.de>,
	David Gundersen <gundy@iinet.net.au>,
	Will Trives <will@trivescon.com.au>,
	"Alexander Y. Fomichev" <gluk@php4.ru>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Daniel Drake <dsd@gentoo.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Philip Craig <philipc@snapgear.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36669 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455AbXKJFdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Nov 2007 00:33:46 -0500
In-Reply-To: <20071108230734.GA15968@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Please pull from branch 'upstream-jeff' in repository
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git upstream-jeff
> 
> to get the changes below.
> 
> They should make things better for people who have experienced the 8168b
> regression since 2.6.24-rc1.
> 
> Distance from 'master' (f2511f13daaf00fdd206bee7b108f75923a613c6)
> -----------------------------------------------------------------
> 
> 407b35429151dd1d7a64cbef9f4bc59dac2efe5d
> d981c1de3b81edf50fe59f0e1298668919117b14
> 9d891d0bb0a14bc8184eee45323cb010db4d0db4
> 69b4d070ea49bd7f589776ea471a6988345eeee5
> db1470271c581050dcacc6ed681b9166d30bdba0
> 
> Diffstat
> --------
> 
>  drivers/net/r8169.c |   26 +++++++-------------------
>  1 files changed, 7 insertions(+), 19 deletions(-)
> 
> Shortlog
> --------
> 
> Ciaran McCreesh (1):
>       r8169: add PCI ID for the 8168 in the Abit Fatal1ty F-190HD motherboard
> 
> Francois Romieu (2):
>       r8169: do not enable the TBI for the 8168 and the 81x0
>       r8169: prevent bit sign expansion error in mdio_write
> 
> Mark Lord (2):
>       r8169: revert 7da97ec96a0934319c7fbedd3d38baf533e20640 (partly)
>       r8169: revert 7da97ec96a0934319c7fbedd3d38baf533e20640 (bis repetita)
> 

pulled


