From: Andrew Morton <akpm@osdl.org>
Subject: Fw: Re: 2.6.12-rc2-mm2
Date: Fri, 8 Apr 2005 09:36:30 -0700
Message-ID: <20050408093630.0ff78c67.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Indrek Kruusa <indrek.kruusa@tuleriit.ee>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Fri, 08 Apr 2005 15:25:16 +0300
From: Indrek Kruusa <indrek.kruusa@tuleriit.ee>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org
Subject: Re: 2.6.12-rc2-mm2


Andrew Morton wrote:

>ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.12-rc2/2.6.12-rc2-mm2/
>  
>

Wow... it responds despite the load average of 83.63 :)

http://www.tuleriit.ee/progs/img/pic1.png
http://www.tuleriit.ee/progs/img/pic2.png
http://www.tuleriit.ee/progs/img/pic3.png


dmesg is not clean though:

TCP: time wait bucket table overflow
TCP: time wait bucket table overflow
TCP: time wait bucket table overflow
printk: 392 messages suppressed.
TCP: time wait bucket table overflow
printk: 290 messages suppressed.
TCP: time wait bucket table overflow
TCP: time wait bucket table overflow
TCP: time wait bucket table overflow
TCP: time wait bucket table overflow
TCP: time wait bucket table overflow
TCP: time wait bucket table overflow
TCP: time wait bucket table overflow
TCP: time wait bucket table overflow
TCP: time wait bucket table overflow
TCP: time wait bucket table overflow
printk: 295 messages suppressed.
TCP: time wait bucket table overflow


What I did:
- "bombing" httpd with JMeter (from another computer)
- copying files from USB memory device to harddisk
- copying file with scp


Indrek
