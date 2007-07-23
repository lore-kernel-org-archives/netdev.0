From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH]: revised make xfrm_audit_log more generic patch
Date: Mon, 23 Jul 2007 18:27:07 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707231826470.9471@d.namei>
References: <200707232146.l6NLk50u001083@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-audit@redhat.com, sgrubb@redhat.com
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:55320 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbXGWW1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 18:27:10 -0400
In-Reply-To: <200707232146.l6NLk50u001083@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Jul 2007, Joy Latten wrote:

> Revised patch that modifies xfrm_audit_log() such that it
> can accomodate auditing other ipsec events
> besides add/delete of an SA or SPD entry.
> 
> This patch differs from original in that it does
> not remove existing ipsec audit defines so as
> to not break existing audit apps. 
> 
> This is a small change to accomodate updating
> ipsec protocol to RFCs 4301, 4302 and 4303 which
> require auditing some ipsec events if auditing
> is available. Please let me know if ok.
> 
> Regards,
> Joy
> 
> Signed-off-by: Joy Latten <latten@austin.ibm.com>

Acked-by: James Morris <jmorris@namei.org>




-- 
James Morris
<jmorris@namei.org>
