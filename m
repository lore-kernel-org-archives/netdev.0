From: jchapman@katalix.com
Subject: Re: How to improve small packet performance
Date: Fri,  8 Aug 2003 12:38:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060364337.3f33e0318bf82@webmail.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Try the latest e100 development driver from sf.net/projects/e1000. Make sure 
you compile it with NAPI enabled.

- jc

minnie wu wrote:

> Hi, all!
>      I'm working on e100/eepro100, kernel version 2.4.20. I used NAPI, but
> the 64 bit small packet dual throughout is only 28M/s. How to improve small
> packet performance further?





-------------------------------------------------
This mail sent through IMP: http://horde.org/imp/
