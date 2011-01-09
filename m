From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and coding-style
Date: Mon, 10 Jan 2011 00:06:25 +0100
Message-ID: <201101100006.26099.christoph.paasch@uclouvain.be>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be> <20110109223033.GA9485@p183.telecom.by> <201101092339.32378.christoph.paasch@uclouvain.be>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201101092339.32378.christoph.paasch@uclouvain.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sunday, January 09, 2011 wrote Christoph Paasch:
> BTW: shouldn't linux/tcp.h include linux/dmaengine.h ? It has a refer=
ence
> to "struct dma_pinned_list"
Ups, sorry for that. The include is at line 209.

I just looked at the head of linux/tcp.h ;)

Christoph

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
