From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: [PATCH 2/2][NET] rename struct tcp_listen_opt to struct listen_sock
Date: Wed, 25 May 2005 22:26:21 -0300
Message-ID: <39e6f6c70505251826381aefad@mail.gmail.com>
References: <20050524011758.GJ26989@conectiva.com.br>
	 <20050525.163716.88475834.davem@davemloft.net>
	 <cbec11ac0505251652657a2dc1@mail.gmail.com>
Reply-To: acme@ghostprotocols.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ian McDonald <imcdnzl@gmail.com>
In-Reply-To: <cbec11ac0505251652657a2dc1@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 5/25/05, Ian McDonald <imcdnzl@gmail.com> wrote:
> David/Arnaldo,
> 
> 
> On 26/05/05, David S. Miller <davem@davemloft.net> wrote:
> > From: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
> > Date: Mon, 23 May 2005 22:17:58 -0300
> >
> > > rsync://rsync.kernel.org/pub/scm/linux/kernel/git/acme/net-2.6.13.git
> >
> > Both changes look good, pulled.  It should show up on kernel.org
> > in a little bit.
> >
> >
> Maybe I am looking at the wrong place but when I look at:
> http://kernel.org/git/?p=linux/kernel/git/acme/net-2.6.13.git;a=summary
> 
> it shows non-network related patches in there as well. Is this intentional?

Its because I cloned David's tree that cloned Linus tree that... i.e.
that summary
is of the last changesets, not necessarily mine or commited by me.
