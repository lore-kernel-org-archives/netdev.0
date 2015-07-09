From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next]Add Maximum Rx packet size supported(rx_buf_sz)
 variable on main structure
Date: Fri, 10 Jul 2015 00:21:58 +0200
Message-ID: <20150709222158.GC12705@electric-eye.fr.zoreil.com>
References: <CAGg4U=HsHML2CKm0fgGoi=AZwXDeZpiGJigodAHJP-ehP58pHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marian Corcodel <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57031 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251AbbGIWWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 18:22:11 -0400
Content-Disposition: inline
In-Reply-To: <CAGg4U=HsHML2CKm0fgGoi=AZwXDeZpiGJigodAHJP-ehP58pHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marian Corcodel <corcodel.marian@gmail.com> :
> Variable  rx_buf_sz have different values on rt8101/8102 is 16000
> bytes instead of 16383 and now is ready do set these.

Where does this come from ? Datasheet ? Experimental evidence ?

-- 
Ueimor
