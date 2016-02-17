From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next] bnx2x: Add missing HSI for big-endian machines
Date: Wed, 17 Feb 2016 14:06:43 +0000
Message-ID: <CO2PR11MB008837CED01B07A4FE88E2E497AE0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1455707714-5262-1-git-send-email-Yuval.Mintz@qlogic.com>
 <56C47D4A.50302@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0118.outbound.protection.outlook.com ([157.56.110.118]:60960
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964898AbcBQOju convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 09:39:50 -0500
In-Reply-To: <56C47D4A.50302@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Commit e5d3a51cefbb "bnx2x: extend DCBx support" was missing HSI
> changes
>     You forgot to also enclose the commit summary in parens.

Good to see we've managed to fix everything else.
:-)
