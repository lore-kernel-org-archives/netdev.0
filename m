From: "Seong Moon" <seong@etri.re.kr>
Subject: IP, MAC address duplication detection ?
Date: Thu, 27 Mar 2003 10:43:21 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <003401c2f402$3fbc4450$28acfe81@seong>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, there.

In Linux box, How can I detect IP/MAC address duplication?
I'm using kernel-2.4.18 but the kernel does not seem to have
gratuitous arp implementation. Is it right?

I know I can detect IP address duplication by arping program
But I want to implment a following mechanism.

When the linux machine bootstraps or one of the nework interfaces
is assigned a MAC/IP address, the linux box can detect the duplication
of newly assigned MAC/IP address. How can I do this ?

thanks.
