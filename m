From: =?koi8-r?Q?=22=E1=CE=C1=D4=CF=CC=C9=CA=20=F7=C5=D2=C8=CF=D7=D3=CB=C9=CA=22=20?= <xx13@mail.ru>
Subject: forcedeth halts system
Date: Sat, 21 Feb 2004 13:18:20 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1AuUDE-000Nx5-00.xx13-mail-ru@f17.mail.ru>
Reply-To: =?koi8-r?Q?=22=E1=CE=C1=D4=CF=CC=C9=CA=20=F7=C5=D2=C8=CF=D7=D3=CB=C9=CA=22=20?= <xx13@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 8bit
Cc: c-d.hailfinger.kernel.2004@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I have nforce2 based system, and chaintech mobo (7nif2).  I'm runnig gentoo, 
with stock kernels from kernel.org.  2.4.22 with nvnet works fine.  Now i'm 
trying to move over to kernel 2.6 (the mobo has lots of buggy ACPI code). 
I've tried 2.6.1 2.6.2 (with forcedeth patches 23) and 2.6.3 (comes with forcedeth).

With each 2.6 kernel i have the same problem, the system halts at random times
and there's nothing helpfull i can find in the logs.  Averge uptime is something 
like 4 hours.  I think there is a correlation between launching of bittorent 
and mldonkey and system crashes.  I'm not 100% sure that the reason for halts is 
the forcedeth driver, but it is my first suspect. 

(What i should do is run the system for couple of days without loading the network 
driver to see if that improves the stability, but living without network is hard.)

Cheers

Anatoly V.
