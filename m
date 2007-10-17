From: Rick Jones <rick.jones2@hp.com>
Subject: Re: bizarre network timing problem
Date: Wed, 17 Oct 2007 15:16:31 -0700
Message-ID: <471689BF.2040909@hp.com>
References: <20071017205127.GA21334@codeblau.de> <47167BDE.4000103@redhat.com> <20071017220019.GA22765@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, linux-kernel@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Felix von Leitner <felix-linuxkernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:40974 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754149AbXJQWQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 18:16:33 -0400
In-Reply-To: <20071017220019.GA22765@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the packet trace was a bit too cooked perhaps, but there were indications that 
at times the TCP window was going to zero - perhaps something with window 
updates or persist timers?

rick jones
