From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek RTL8111B serious performance issues
Date: Wed, 18 Jul 2007 09:26:35 +0200
Message-ID: <20070718072635.GA26243@electric-eye.fr.zoreil.com>
References: <Pine.SOC.4.64.0707172328150.3299@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: john@BlueSkyTours.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47603 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752627AbXGRH3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 03:29:18 -0400
Content-Disposition: inline
In-Reply-To: <Pine.SOC.4.64.0707172328150.3299@katana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

john@BlueSkyTours.com <john@BlueSkyTours.com> :
[...]
> Anyone have any suggestions for solving this problem?

Try 2.6.23-rc1 when it is published or apply against 2.6.22 one of:
http://www.fr.zoreil.com/people/francois/misc/20070628-2.6.22-rc6-r8169-test.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/r8169-20070628/

-- 
Ueimor
