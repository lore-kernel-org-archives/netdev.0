From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] NET: llc, zero sockaddr_llc struct
Date: Sun, 23 Aug 2009 22:55:59 -0700 (PDT)
Message-ID: <20090823.225559.62651309.davem@davemloft.net>
References: <20090823.185617.36449822.davem@davemloft.net>
	<1251092619-3368-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	acme@ghostprotocols.net
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751557AbZHXFzr@vger.kernel.org>
In-Reply-To: <1251092619-3368-1-git-send-email-jirislaby@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jirislaby@gmail.com>
Date: Mon, 24 Aug 2009 07:43:39 +0200

> sllc_arphrd member of sockaddr_llc might not be changed. Zero sllc
> before copying to the above layer's structure.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

Applied, thanks Jiri.
