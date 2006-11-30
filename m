From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/1] additional ipsec audit patch
Date: Wed, 29 Nov 2006 19:30:53 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611291918530.28053@d.namei>
References: <200611292348.kATNmfMa001526@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, sgrubb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:6104 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S967729AbWK3Aa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 19:30:57 -0500
To: Joy Latten <latten@austin.ibm.com>
In-Reply-To: <200611292348.kATNmfMa001526@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Nov 2006, Joy Latten wrote:

> This patch disables auditing in ipsec when CONFIG_AUDITSYSCALL is
> disabled in the kernel. 
> 
> This patch also includes a bug fix for xfrm_state.c as a result of
> original ipsec audit patch.
> 
> Let me know if it looks ok.


Also, the last patch contains no Signed-off-by: line, please resend.


-- 
James Morris
<jmorris@namei.org>
