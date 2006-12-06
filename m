From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][GENETLINK] fix misplaced command flags
Date: Wed, 06 Dec 2006 09:23:44 -0800 (PST)
Message-ID: <20061206.092344.52166262.davem@davemloft.net>
References: <1165424543.3749.2.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54036
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S936902AbWLFRXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 12:23:35 -0500
To: hadi@cyberus.ca
In-Reply-To: <1165424543.3749.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 06 Dec 2006 12:02:23 -0500

> fixes something i broke in previous patch. Against net-2.6.20.
> BTW, is it just me having problems syncing net-2.6.20?

You should be using the net-2.6.git tree now, I blow away the
net-2.6.X.git tree when 2.6.X integration starts happening and just do
everything from net-2.6.git


