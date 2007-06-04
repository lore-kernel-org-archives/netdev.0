From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Mon, 4 Jun 2007 19:13:10 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0706041911480.15240@d.namei>
References: <200703262321.l2QNLZlR014240@faith.austin.ibm.com>
 <1180983953.3950.37.camel@localhost.localdomain> <Line.LNX.4.64.0706041544230.13341@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	Joy Latten <latten@austin.ibm.com>
To: Eric Paris <eparis@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:38371 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924AbXFDXNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 19:13:12 -0400
In-Reply-To: <Line.LNX.4.64.0706041544230.13341@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've applied this patch to 

git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-2.6.git#for-davem


Dave, feel free to pull from that branch.



- James
-- 
James Morris
<jmorris@namei.org>
