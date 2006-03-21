From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] scm: fold __scm_send() into scm_send()
Date: Mon, 20 Mar 2006 19:37:51 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0603201936030.6749@excalibur.intercode>
References: <200603201244.58507.netdev@axxeo.de> <20060320201802.GS15997@sorel.sous-sol.org>
 <20060320213636.GT15997@sorel.sous-sol.org> <20060320.152838.68858441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: chrisw@sous-sol.org, cxzhang@watson.ibm.com, netdev@axxeo.de,
	ioe-lkml@rameria.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751388AbWCUAh5@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060320.152838.68858441.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Mar 2006, David S. Miller wrote:

> I'm seriously considering backing out Catherine's AF_UNIX patch from
> the net-2.6.17 tree before submitting it to Linus later today so that
> none of this crap goes in right now.

I believe Catherine is away this week, so it's probably best to drop the 
code and wait till she gets back and we can get it 100% right.

Sorry, this is my fault, I should have caught this problem.



- James
-- 
James Morris
<jmorris@namei.org>
