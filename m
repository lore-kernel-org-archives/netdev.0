From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] rtnetlink: add babel protocol recognition
Date: Fri, 07 Nov 2014 16:58:25 -0500 (EST)
Message-ID: <20141107.165825.1228557314978084380.davem@redhat.com>
References: <20141106081014.38a23889@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave.taht@bufferbloat.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56538 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbaKGV65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 16:58:57 -0500
In-Reply-To: <20141106081014.38a23889@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 6 Nov 2014 08:10:14 -0800

> From: Dave Taht <dave.taht@bufferbloat.net>
> 
> Babel uses rt_proto 42. Add to userspace visible header file.
> 
> Signed-off-by: Dave Taht <dave.taht@bufferbloat.net>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
