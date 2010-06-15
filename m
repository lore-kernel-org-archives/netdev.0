From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: unify tcp flag macros
Date: Tue, 15 Jun 2010 11:56:44 -0700 (PDT)
Message-ID: <20100615.115644.35044372.davem@davemloft.net>
References: <1276387303-25892-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276387303-25892-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>
Date: Sun, 13 Jun 2010 08:01:43 +0800

> unify tcp flag macros: TCPHDR_FIN, TCPHDR_SYN, TCPHDR_RST, TCPHDR_PSH,
> TCPHDR_ACK, TCPHDR_URG, TCPHDR_ECE and TCPHDR_CWR. TCBCB_FLAG_* are replaced
> with the corresponding TCPHDR_*.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks.
