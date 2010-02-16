From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] net ipv4: Decouple ipv4 interface
 parameters from binary sysctl numbers
Date: Tue, 16 Feb 2010 15:55:28 -0800 (PST)
Message-ID: <20100216.155528.172308732.davem@davemloft.net>
References: <m1fx54kkyo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46321
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933615Ab0BPXzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:55:15 -0500
In-Reply-To: <m1fx54kkyo.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 14 Feb 2010 05:25:51 -0800

> 
> Stop using the binary sysctl enumeartion in sysctl.h as an index into
> a per interface array.  This leads to unnecessary binary sysctl number
> allocation, and a fragility in data structure and implementation
> because of unnecessary coupling.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied.
