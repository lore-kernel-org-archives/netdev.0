From: Michael Iatrou <m.iatrou@freemail.gr>
Subject: Re: e1000 (?) jumbo frames performance issue
Date: Fri, 6 May 2005 01:26:09 +0300
Message-ID: <200505060126.09062.m.iatrou@freemail.gr>
References: <200505051928.32496.m.iatrou@freemail.gr> <427A7F5B.8050704@hp.com> <200505060055.55778.m.iatrou@freemail.gr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-7"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <200505060055.55778.m.iatrou@freemail.gr>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When the date was Friday 06 May 2005 00:55, Michael Iatrou wrote:

> > You could try some tests adding a test-specific -D to
> > disable Nagle, or -C to set TCP_CORK, or use -m to set the send size to
> > say, 32KB.
>
> I 've already tested -m 32KB and its the same as 16KB.
> I will try -D and -C too.

Done, (almost) nothing changed.

-- 
 Michael Iatrou
 Electrical and Computer Engineering Dept.
 University of Patras, Greece
