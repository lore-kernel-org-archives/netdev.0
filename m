From: Elmer <elmer@linking.ee>
Subject: Re: patches for PROC_FS=n (2.6.0-test7)
Date: Mon, 13 Oct 2003 13:31:30 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310131328400.21697-100000@server>
References: <20031012201316.7ecf73c8.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Noah J. Misch" <noah@caltech.edu>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
        "davem@redhat.com" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20031012201316.7ecf73c8.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



arlan.c is ok without arlan-proc.c
as init_arlan_proc is in arlan-proc.c, it shoult be
OK, as long as radio parameters are saved into cards ROM.

I have forgot a lot about that code, of course.



Elmer
