From: James Morris <jmorris@redhat.com>
Subject: Re: [RFC] moving the test for sockaddr->sa_family up
Date: Sun, 16 Nov 2003 08:56:04 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0311160855020.31201-100000@thoron.boston.redhat.com>
References: <20031115212034.GA16326@conectiva.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20031115212034.GA16326@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 15 Nov 2003, Arnaldo Carvalho de Melo wrote:

> Does anybody see any problem with this simplification? Not for 2.6.0, of
> course...

No, looks like a good idea.  Might be able to push address length 
verification up there too.


- James
-- 
James Morris
<jmorris@redhat.com>
