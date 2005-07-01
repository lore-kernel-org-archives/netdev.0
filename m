From: "Raz Ben-Jehuda(caro)" <raziebe@gmail.com>
Subject: general bonding question
Date: Fri, 1 Jul 2005 11:00:11 +0200
Message-ID: <5d96567b05070102001fc7b677@mail.gmail.com>
Reply-To: "Raz Ben-Jehuda(caro)" <raziebe@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

To any of you that deal with the nic bonding driver.
Is there a special reason why the bond interface is not using
the slave device features, such as "scatter gather" or hardware checksum ?
I think of fixing the driver but i thought it would better to advise first.   

-- 
Raz
Long Live the Penguin
