From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH -next] qed: Use DEFINE_SPINLOCK() for spinlock
Date: Tue, 2 Aug 2016 14:04:00 +0000
Message-ID: <CO2PR11MB0088C022197DB1FCEAD4784F97050@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1470145740-17392-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0130.outbound.protection.outlook.com ([104.47.40.130]:56224
	"EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756837AbcHBOiw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 10:38:52 -0400
In-Reply-To: <1470145740-17392-1-git-send-email-weiyj.lk@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> spinlock can be initialized automatically with DEFINE_SPINLOCK() rather than
> explicitly calling spin_lock_init().
> 
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Seems reasonable, although afaik net-next is still closed.
Thanks.

Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
