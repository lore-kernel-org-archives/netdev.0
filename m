From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: Re: /proc/sys/net/ipv4/tcp_*
Date: Mon, 28 Jun 2004 12:52:37 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0406281250550.4884-100000@orchestra.cs.caltech.edu>
References: <20040628194452.51849.qmail@web54108.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev linux <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Weiguang Shi <wgshi2002@yahoo.ca>
In-Reply-To: <20040628194452.51849.qmail@web54108.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> Where can I find a more readable documentation than the code for these files
> (for kernel 2.4.20, and yes RH9)?

http://datatag.web.cern.ch/datatag/publications.html

see "A Map of the Networking Code in Linux Kernel 2.4.20"

> A third question: what does FLAG_ECE mean in tcp_input.c?

if an ack carries explicit congestion notification.
