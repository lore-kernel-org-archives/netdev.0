From: Jan Olderdissen <jan@ixiacom.com>
Subject: RE: [PATCH 2.6.5] Re: Fw: Stack sends SYN/ACKs even though accept
	 queue is full
Date: Mon, 3 May 2004 20:10:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15FDCE057B48784C80836803AE3598D50627AC99@racerx.ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@oss.sgi.com, David Miller <davem@redhat.com>,
        Andrew Morton
	 <akpm@osdl.org>, Thomas Ameling <tameling@ixiacom.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Nivedita Singhvi'" <niv@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita,

> Attaching a patch which adds a sysctl to turn off this
> behaviour.   Could you test this, please?  Patch against
> 2.6.5 vanilla kernel.  If you need a 2.4 version, let me
> know.

Thomas tested your patch against 2.6.5 with success. The patch didn't apply
cleanly against the sources he was using, but after some twiddling it did
the job. Internally, we'll use the 2.4.21 patch, of course. Thanks!

Jan
