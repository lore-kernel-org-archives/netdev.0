From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 2.5.69] Bug in sys_accept() module ref counts
Date: Tue, 6 May 2003 21:43:49 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507004348.GC27162@conectiva.com.br>
References: <Pine.LNX.4.44.0305061223090.1348-100000@dyn9-47-18-140.beaverton.ibm.com> <20030507001418.GA27162@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20030507001418.GA27162@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Tue, May 06, 2003 at 09:14:19PM -0300, Arnaldo C. Melo escreveu:
> Em Tue, May 06, 2003 at 12:28:41PM -0700, Sridhar Samudrala escreveu:

> > Also i think we should do a __module_get() with newsock's owner(although
> > same as the original listening sock).

Forget about the comment, its what you said above, sorry for answering too fast
8)

- Arnaldo
