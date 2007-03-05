From: James Morris <jmorris@namei.org>
Subject: RE: [PATCH] xfrm_policy delete security check misplaced
Date: Mon, 5 Mar 2007 11:39:29 -0500 (EST)
Message-ID: <Line.LNX.4.64.0703051139040.14821@d.namei>
References: <001501c75f3f$243a3000$cc0a010a@tcssec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: 'Eric Paris' <eparis@parisplace.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, jmorris@namei.org,
	Venkat Yekkirala <vyekkirala@tcsfw4.tcs-sec.com>,
	cxzhang@watson.ibm.com, Stephen Smalley <sds@tycho.nsa.gov>
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:57692 "EHLO
	mail2.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933562AbXCEQjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 11:39:33 -0500
In-Reply-To: <001501c75f3f$243a3000$cc0a010a@tcssec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Mar 2007, Venkat Yekkirala wrote:

> > 
> > Signed-off-by: Eric Paris <eparis@redhat.com>
> Acked-by: Venkat Yekkirala <vyekkirala@trustedcs.com> 

What about your previous comment:

 "I guess you meant to do this here?
        else if (err)
                return err; "




-- 
James Morris
<jmorris@namei.org>
