From: James Morris <jmorris@namei.org>
Subject: RE: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 27 Apr 2006 00:58:41 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0604270055010.6286@d.namei>
References: <54AD0F12E08D1541B826BE97C98F99F143AE6C@NT-SJCA-0751.brcm.ad.broadcom.com>
 <1146109226.11864.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Caitlin Bestler <caitlinb@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>, kelly@au1.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:61873 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964905AbWD0E6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 00:58:43 -0400
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <1146109226.11864.37.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Apr 2006, Rusty Russell wrote:

> netfilter (similarly raw sockets, bonding, divert).  Or, we could delay
> LOCAL_IN hook processing until we get to socket receive.

This an idea proposed for skfilter [1], too, allowing packets to be 
filtered by local endpoint.


[1] http://people.redhat.com/jmorris/selinux/skfilter/



-- 
James Morris
<jmorris@namei.org>
