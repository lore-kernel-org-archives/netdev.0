From: sakalra@hss.hns.com
Subject: Help for GCOV in MVL 2.4.18 Prof. version
Date: Tue, 17 Jun 2003 18:31:27 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF1DD18AC3.65DE1968-ON65256D48.00467BF8@hss.hns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org






hi ,

  I am trying with some profiling and coverage for my code on Montavista
2.4.18 (linux2.4.18_mvl30) Professional edition. The GCOV patch for 2.4.18
(I suppose its for RedHat kernel) fails. I tried applying it manually but
then it was creating problems while profiling my driver. When i tried
running gcov on file.c at path /proc/module/opt/hardhat/mydriver/file1.c,
GCOV abrubtly ends saying "Aborted". There is a  file1.da  created at this
location once i have loaded the gcov-proc.o..

I want to know whether there is any seperate patch available for MVL or its
the same patch.

If someone has tried this then kindly help in this regards,

tia,
-Sandeep kalra
