From: Andrey Bondarenko <bondarenko007@aport2000.ru>
Subject: /dev/ptyXX 2.6.8 problem
Date: Sat, 14 Aug 2004 13:34:27 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200408141334.27402.bondarenko007@aport2000.ru>
Reply-To: bondarenko007@aport2000.ru
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mostrows@styx.uwaterloo.ca
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

I had found an issue in the 2.6.8 kernel, I don't know correct person to 
report, but I hope you will mind much. Well, I had 2.6.7 kernel, everything 
was OK, I had compiled 2.6.8 with same settings and found, that I can not run 
xterm (or other terminal), and when I run MC from console, it reports, that 
it can not open pty's. I had googled round and found 
(http://seclists.org/lists/linux-kernel/2004/Aug/1097.html) same problem and 
solution for it - kill everything, that uses /dev/pts/XX. So I had killed 
pppd, run Xterm - everything was OK. Than I run pppd again (I can not live 
without my ppp-oe), but xterm remanis working and problem seems to disappear. 

Problem is quite annoying and very strange. Thank you for your time.

-- 

With best regards,
	Andrey "Shaman" Bondarenko

This message does not contain any viruses.
