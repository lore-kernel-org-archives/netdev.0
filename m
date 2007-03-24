From: Florian Zumbiehl <florz@gmx.de>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Sat, 24 Mar 2007 01:22:42 +0100
Message-ID: <20070324002242.GA26017@florz.florz.dyndns.org>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [77.10.160.141] ([77.10.160.141]:3693 "EHLO
	rain.florz.dyndns.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S2992634AbXCXA4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 20:56:36 -0400
Content-Disposition: inline
In-Reply-To: <200703232307.l2NN7Rtg010808@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> + * 251003 :	Copied from pppoe.c version 0.6.9.

you might want to have a look at the patches to the PPPoE code that were
posted to netdev recently, as some of them seem to apply to code that's
left over from pppoe.c.

Florian
