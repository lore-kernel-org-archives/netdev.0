From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: ifconfig TX/RX errors
Date: Fri, 8 Nov 2002 14:59:01 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33L0.0211081456190.25749-100000@fast2.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, all

What does a large number of RX/TX errors from ifconfig output generally
mean?  Does it also include drop/overruns/frame errors?

Is it an indication of bad packet on the link layer, which  probably means
faulty hardware?  I am assuming any kind of buffer overflow statistics are
kept under drop or overruns?

Thanks a lot,

Cheng
Lab # 626 395 8820
