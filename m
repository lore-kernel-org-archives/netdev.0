From: "Xiaoliang \(David\) Wei" <weixl@caltech.edu>
Subject: How can we bound one CPU to one Gigabit NIC?
Date: Mon, 7 Oct 2002 11:11:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <03ab01c26e2d$06adeac0$f5f2010a@weixl>
References: <Pine.GSO.4.30.0210070749430.1861-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Everyone,
      I am now doing some experiments on Dual CPU (2.4Ghz) with 2 Gigabit
cards. Can anyone tell me how to bound one CPU to each NIC so that we don't
need to care about the packet-reordering and the interrupt sharing problems?
      Thank you very much.:)



Xiaoliang (David) Wei             Graduate Student in CS@Caltech
http://www.cs.caltech.edu/~weixl
====================================================
