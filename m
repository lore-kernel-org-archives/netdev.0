From: Frank Denis <jedi@orbus.fr>
Subject: Re: nfsd oops with 2.6.5-rc2-mm4
Date: Sun, 28 Mar 2004 10:04:23 +0159
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403281005.01064.jedi@orbus.fr>
References: <20040327130757.GA6760@c9x.org> <Pine.LNX.4.58.0403271816450.20100@ppc970.osdl.org> <20040327184840.20d9e282.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Linus Torvalds <torvalds@osdl.org>, davem@redhat.com,
        trond.myklebust@fys.uio.no, neilb@cse.unsw.edu.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040327184840.20d9e282.akpm@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Le dimanche 28 Mars 2004 04:48, Andrew Morton a =E9crit=A0:
> This one might be the cuplrit:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.5-rc2=
/2.6
>.5-rc2-mm4/broken-out/knfsd-03-auth_error-formatting-fix.patch

Bad pick, same oops when that one is reverted.

Let's try other ones...
