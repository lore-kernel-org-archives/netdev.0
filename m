From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/1] additional ipsec audit patch
Date: Wed, 29 Nov 2006 19:32:34 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611291932200.28199@d.namei>
References: <200611292348.kATNmfMa001526@faith.austin.ibm.com>
 <XMMS.LNX.4.64.0611291918530.28053@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, sgrubb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:38356 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S967734AbWK3Acg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 19:32:36 -0500
To: Joy Latten <latten@austin.ibm.com>
In-Reply-To: <XMMS.LNX.4.64.0611291918530.28053@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Nov 2006, James Morris wrote:

> On Wed, 29 Nov 2006, Joy Latten wrote:
> 
> > This patch disables auditing in ipsec when CONFIG_AUDITSYSCALL is
> > disabled in the kernel. 
> > 
> > This patch also includes a bug fix for xfrm_state.c as a result of
> > original ipsec audit patch.
> > 
> > Let me know if it looks ok.
> 
> 
> Also, the last patch contains no Signed-off-by: line, please resend.

And, what is the testing status of these patches?


-- 
James Morris
<jmorris@namei.org>
