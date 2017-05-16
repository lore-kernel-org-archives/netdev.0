From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH v2 30/53] net: fix some identation issues at kernel-doc markups
Date: Tue, 16 May 2017 13:38:17 +0100
Message-ID: <15466.1494938297@warthog.procyon.org.uk>
References: <d651983dde41a854e25664d98cbfc999d55785a8.1494935649.git.mchehab@s-opensource.com> <cover.1494935649.git.mchehab@s-opensource.com> <cover.1494935649.git.mchehab@s-opensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com,
        Linux Doc Mailing List <linux-doc@vger.kernel.org>,
        Mauro Carvalho Chehab <mchehab@infradead.org>,
        linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Marek Vasut <marek.vasut@gmail.com>,
        Richard Weinberger <richard@nod.at>,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>,
        linux-mtd@lists.infradead.org, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <alexa
To: Mauro Carvalho Chehab <mchehab@s-opensource.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <d651983dde41a854e25664d98cbfc999d55785a8.1494935649.git.mchehab@s-opensource.com>
Content-ID: <15465.1494938297.1@warthog.procyon.org.uk>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mauro Carvalho Chehab <mchehab@s-opensource.com> wrote:

> - *	calling skb_free_datagram). Returns NULL with *err set to
> + *	calling skb_free_datagram). Returns NULL with @err set to

I think this should be *@err or @*err.  err is not itself changed.

David
