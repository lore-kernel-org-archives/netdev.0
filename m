From: =?iso-8859-1?q?Jambunathan=20Kalyanasundaram?= <k_jambunathan@yahoo.co.uk>
Subject: TProxy, 2.4 Kernel and NetFilter
Date: Mon, 9 Feb 2004 07:56:44 +0000 (GMT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209075644.11922.qmail@web25110.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netfilter-devel@lists.netfilter.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

( Sorry for posting in two mailing lists at the same
time )

I would like to implement Transparent HTTP Proxy  and
I have scoured through your archives for the related
threads. Can someone confirm that my following
understanding is still valid as of date considering
the latest Linux kernel and Netfilter source tree.

1) For packet interception from browser side, the
standard way is to use REDIRECT target of Netfilter.

2) But if I am not really interested in the overheads
imposed by the NetFilter, the only option is to patch
the Linux kernel with Balazs Scheidler's patch.=20

If I don't like something as heavyweight as Netfilter
and something that is as  "non standard" as patching
the kernel, are there any ways out ?=20

Also are there any existing NetFilter modules that
work on a standard, unpatched kerenel that allow proxy
to talk to the web server as though it's the web
browser ( source address spoofing ) ?

Regards,
Jambunathan K.




=09
=09
	=09
___________________________________________________________
BT Yahoo! Broadband - Free modem offer, sign up online today and save =A3=
80 http://btyahoo.yahoo.co.uk
