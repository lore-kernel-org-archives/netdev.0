From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Mon, 14 May 2007 13:09:44 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902D7E2FD@orsmsx414.amr.corp.intel.com>
References: <1179149418.15622.79.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>, "Thomas Graf" <tgraf@suug.ch>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	<netdev@vger.kernel.org>
To: <hadi@cyberus.ca>, "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56706 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757508AbXENUJq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 16:09:46 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1179149418.15622.79.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Incoporating last comments from Patrick.
> Dave, I think this is ready to apply - against net-2.6 from 
> this morning. 

Aside from the whitespace changes, I've run this patch over the weekend
with no issue under moderate stress.  Looks fine to me.

Thx,

-PJ Waskiewicz
