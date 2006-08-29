From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 5/6] NetLabel: uninline selinux_netlbl_inode_permission()
Date: Tue, 29 Aug 2006 12:54:40 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608291254010.29142@d.namei>
References: <20060829144251.452774000@hp.com> <20060829144446.837714000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:55769 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751124AbWH2Qyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 12:54:43 -0400
To: Paul Moore <paul.moore@hp.com>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060829144446.837714000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Aug 2006, paul.moore@hp.com wrote:

> Uninline the selinux_netlbl_inode_permission() at the request of Andrew Morton.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Acked-by: James Morris <jmorris@namei.org>


These patches should likely go in via Dave's tree.



-- 
James Morris
<jmorris@namei.org>
