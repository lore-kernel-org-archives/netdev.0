From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV4 IPComp : threshold comparison
Date: Sat, 17 May 2003 22:34:23 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030517.223423.26296484.davem@redhat.com>
References: <87smrda4q6.wl@karaba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mk@linux-ipv6.org
In-Reply-To: <87smrda4q6.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Mitsuru KANDA / 神田 充 <mk@linux-ipv6.org>
   Date: Sun, 18 May 2003 02:00:01 +0900

   ===== ipcomp.c 1.6 vs edited =====
   --- 1.6/net/ipv4/ipcomp.c	Tue May 13 05:58:03 2003
   +++ edited/ipcomp.c	Sun May 18 01:42:22 2003

I am applying this, but please you USAGI guys start to
generate properly rooted patched for me ok?

I want something of the form:

   --- a/net/ipv4/ipcomp.c	Tue May 13 05:58:03 2003
   +++ b/net/ipv4/ipcomp.c	Sun May 18 01:42:22 2003

Almost everyone sends me patches like this, USAGI are
the one exception.  If everyone sends me patches this
way, then all of my patch applying scripts know they can
simply use "patch -p1" when sitting at top of kernel tree.

Probably all of the USAGI patches look this way because of
CVS or something like that.

Thank you.
