From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 13 Jun 2007 09:44:02 -0700
Message-ID: <46701ED2.7070208@hp.com>
References: <466DEF9D.9070509@trash.net>	<1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>	<20070612.140240.00078635.davem@davemloft.net> <466F0C92.5080306@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	kaber@trash.net, hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:56138 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758356AbXFMQoJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 12:44:09 -0400
In-Reply-To: <466F0C92.5080306@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm starting to wonder how a multi-queue NIC differs from a bunch of 
bonded single-queue NICs, and if there is leverage opportunity there.

rick jones
