From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: allow adding VLANs while interface is down
Date: Sat, 4 Jun 2016 05:28:46 +0000
Message-ID: <CO2PR11MB00888A27698FB53DB4046D3C975A0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1464960738-8541-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>
To: Michal Schmidt <mschmidt@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0105.outbound.protection.outlook.com ([65.55.169.105]:60082
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750718AbcFDFoM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 01:44:12 -0400
In-Reply-To: <1464960738-8541-1-git-send-email-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Since implementing VLAN filtering in commit 05cc5a39ddb74
> ("bnx2x: add vlan filtering offload") bnx2x refuses to add a VLAN while the
> interface is down.

Hi Michal - thanks; I'll review this one on Sunday.
